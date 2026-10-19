#!/usr/bin/env bash
set -euo pipefail
(( $# )) || { echo "usage: $0 ffmpeg [ffmpeg ...]" >&2; exit 1; }
src=${SRC:-~/asue}
shm=${SHM:-/dev/shm/bench}
runs=${RUNS:-3}
start=${START:-60}
secs=${SECS:-30}
fps=24
frames=$((secs * fps))
heavy=$((frames / 10))
threads=$(nproc)
font=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf
bbb=$src/bbb
ff=$1
q="-hide_banner -nostdin -loglevel error -y"
export SVT_LOG=1

rm -rf $shm; mkdir -p $shm
$ff $q -ss $start -i $bbb/big_buck_bunny_1080p24.y4m -frames:v $frames -c:v copy $shm/in.y4m
$ff $q -ss $start -t $secs -i $bbb/BigBuckBunny-surround.flac -c:a pcm_s24le $shm/in51.wav
$ff $q -ss $start -t $secs -i $bbb/BigBuckBunny-stereo.flac -c:a pcm_s24le $shm/in2.wav
$ff $q -i $shm/in.y4m -c:v libx264 -preset medium -crf 23 $shm/h264.mp4
$ff $q -i $shm/in.y4m -c:v libx265 -preset medium -crf 28 -x265-params log-level=error $shm/hevc.mkv
$ff $q -i $shm/in.y4m -c:v libsvtav1 -preset 8 -crf 35 $shm/av1.mkv
$ff $q -i $shm/in.y4m -vf vidstabdetect=result=$shm/in.trf -f null -
for n in $(seq $((start * fps + 1)) $((start * fps + frames))); do printf "%s/png/big_buck_bunny_%05d.png\0" $bbb $n; done | xargs -0 cat >/dev/null
cat $bbb/BigBuckBunny-stereo.flac $bbb/BigBuckBunny-surround.flac >/dev/null
cat > $shm/in.ass <<'ASS'
[Script Info]
ScriptType: v4.00+
PlayResX: 1920
PlayResY: 1080

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, OutlineColour, BorderStyle, Outline, Alignment
Style: Default,DejaVu Sans,64,&H00FFFFFF,&H00000000,1,3,2

[Events]
Format: Layer, Start, End, Style, Text
Dialogue: 0,0:00:00.00,9:59:59.00,Default,Big Buck Bunny {\b1}bench{\b0}
ASS

set -f
y4m="-i $shm/in.y4m"
png="-framerate $fps -start_number $((start * fps + 1)) -i $bbb/png/big_buck_bunny_%05d.png"
tc="drawtext=fontfile=$font:timecode='00\:00\:00\:00':rate=$fps:fontsize=48:fontcolor=white:box=1:x=32:y=32"
sub="subtitles=$shm/in.ass:fontsdir=${font%/*}"

declare -a pnames pcmds
probe() { pnames+=("$1"); pcmds+=("$2"); }
probe "subtitles"  "$y4m -frames:v $fps -vf $sub -f null -"
probe "ass"        "$y4m -frames:v $fps -vf ass=$shm/in.ass:fontsdir=${font%/*} -f null -"
probe "drawtext"   "$y4m -frames:v $fps -vf $tc -f null -"
probe "iccgen"     "$y4m -frames:v $fps -vf setparams=color_primaries=bt709:color_trc=bt709,iccgen,iccdetect -f null -"
probe "zmq"        "$y4m -frames:v $fps -vf zmq -f null -"
probe "azmq"       "-t 1 -i $shm/in2.wav -af azmq -f null -"
probe "sofalizer"  "-t 1 -i $shm/in51.wav -af sofalizer=sofa=$src/SimpleFreeFieldHRIR_1.0.sofa -f null -"
probe "libfdk_aac" "-t 1 -i $shm/in2.wav -c:a libfdk_aac -f null -"
for i in "${!pnames[@]}"; do
  for v in "$@"; do
    if $v $q ${pcmds[$i]} >/dev/null 2>&1; then r=ok; else r=FAIL; fi
    echo "probe ${pnames[$i]}|$v|$r"
  done
done

declare -a names cmds
add() { names+=("$1"); cmds+=("$2"); }
add "job mp4 x264+aac"       "$y4m -i $shm/in51.wav -map 0:v -map 1:a -vf scale=1280:720,$tc -c:v libx264 -preset medium -crf 23 -c:a libfdk_aac -ac 2 -b:a 160k $shm/out1.mp4"
add "job mkv svtav1+opus"    "$y4m -i $shm/in51.wav -map 0:v -map 1:a -c:v libsvtav1 -preset 8 -crf 35 -c:a libopus -b:a 384k -mapping_family 1 $shm/out2.mkv"
add "job mkv x265 png+flac"  "$png -i $shm/in2.wav -map 0:v -map 1:a -frames:v $frames -pix_fmt yuv420p -c:v libx265 -preset medium -crf 28 -x265-params log-level=error -c:a flac -shortest $shm/out3.mkv"
add "job mp4 clean+sub"      "$y4m -i $shm/in2.wav -map 0:v -map 1:a -vf bwdif,hqdn3d,vidstabtransform=input=$shm/in.trf,$sub -c:v libx264 -preset fast -crf 21 -c:a aac -b:a 128k $shm/out4.mp4"
add "enc libx264"            "$y4m -c:v libx264 -preset medium -crf 23 -f null -"
add "enc libx265"            "$y4m -c:v libx265 -preset medium -crf 28 -x265-params log-level=error -f null -"
add "enc libsvtav1"          "$y4m -c:v libsvtav1 -preset 8 -crf 35 -f null -"
add "enc libvpx-vp9"         "$y4m -c:v libvpx-vp9 -deadline good -cpu-used 4 -row-mt 1 -b:v 0 -crf 32 -f null -"
add "dec h264"               "-i $shm/h264.mp4 -f null -"
add "dec hevc"               "-i $shm/hevc.mkv -f null -"
add "dec libdav1d"           "-c:v libdav1d -i $shm/av1.mkv -f null -"
add "dec png"                "$png -frames:v $frames -f null -"
add "vf scale"               "$y4m -vf scale=1280:720:flags=lanczos -f null -"
add "vf zscale"              "$y4m -vf zscale=w=1280:h=720:filter=lanczos -f null -"
add "vf bwdif"               "$y4m -vf bwdif -f null -"
add "vf hqdn3d"              "$y4m -vf hqdn3d -f null -"
add "vf nlmeans"             "$y4m -frames:v $heavy -vf nlmeans -f null -"
add "vf unsharp"             "$y4m -vf unsharp -f null -"
add "vf overlay"             "$y4m -filter_complex [0:v]split[main][pip];[pip]scale=480:-2[small];[main][small]overlay=W-w-32:H-h-32 -f null -"
add "vf vidstabdetect"       "$y4m -vf vidstabdetect=result=$shm/bench.trf -f null -"
add "vf vidstabtransform"    "$y4m -vf vidstabtransform=input=$shm/in.trf -f null -"
add "vf libvmaf"             "-i $shm/h264.mp4 $y4m -lavfi [0:v][1:v]libvmaf=n_threads=$threads -f null -"
add "af aac 5.1>2.0"         "-i $bbb/BigBuckBunny-surround.flac -ac 2 -c:a aac -b:a 160k -f null -"
add "af libfdk_aac 5.1>2.0" "-i $bbb/BigBuckBunny-surround.flac -ac 2 -c:a libfdk_aac -vbr 4 -f null -"
add "af libopus 5.1"         "-i $bbb/BigBuckBunny-surround.flac -c:a libopus -b:a 384k -mapping_family 1 -f null -"
add "af libmp3lame 5.1>2.0"  "-i $bbb/BigBuckBunny-surround.flac -ac 2 -c:a libmp3lame -q:a 2 -f null -"
add "af sofalizer"           "-i $bbb/BigBuckBunny-surround.flac -af sofalizer=sofa=$src/SimpleFreeFieldHRIR_1.0.sofa -f null -"
add "af rubberband"          "-i $bbb/BigBuckBunny-stereo.flac -af rubberband=tempo=1.25 -f null -"
add "af soxr 44.1k"          "-i $bbb/BigBuckBunny-stereo.flac -af aresample=44100:resampler=soxr -f null -"
add "af loudnorm"            "-i $bbb/BigBuckBunny-stereo.flac -af loudnorm -f null -"
add "af afftdn"              "-i $bbb/BigBuckBunny-stereo.flac -af afftdn -f null -"
for i in "${!names[@]}"; do
  for r in $(seq $runs); do
    for v in "$@"; do
      t=$($v -hide_banner -nostdin -benchmark -y ${cmds[$i]} 2>&1 | sed -n 's/.*utime=\([0-9.]*\)s.*rtime=\([0-9.]*\)s.*/\1 \2/p') || t=FAIL
      echo "${names[$i]}|$v|$r|$t"
    done
  done
done
rm -rf $shm
