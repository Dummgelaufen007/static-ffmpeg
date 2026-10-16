#!/usr/bin/env bash

set -uo pipefail

ROOT=$(realpath "${1:?usage: $0 <entpacktes export-verzeichnis>}")
WORST_CASE_SECONDS=120
ARIB_SAMPLE=https://fate-suite.ffmpeg.org/sub/aribcaption_clear.ts
ARIB_SHA256=a349fc7ade98e5e259ee1657aa8cb9db60e9b77b000376956482fd0270b358da
AVS3_SAMPLE=https://raw.githubusercontent.com/xatabhk/avs2-avs3-video-samples/f5e12f4540784fc6b16dd736caca9ffdac44b038/Raw/WindTurbines4_270_ffmepg.avs3
AVS3_10BIT_SAMPLE=https://raw.githubusercontent.com/xatabhk/avs2-avs3-video-samples/f5e12f4540784fc6b16dd736caca9ffdac44b038/Raw/MarketPlace_480x270_60_10bit_ra_ffmpeg.avs3
SOFA_SAMPLE=https://raw.githubusercontent.com/hoene/libmysofa/v1.3.5/tests/tester.sofa
FONTFILE=$ROOT/usr/share/fonts/dejavu/DejaVuSans.ttf

WORK=$(mktemp -d)
cd "$WORK" || exit
cat >fonts.conf <<FONTCONFIG
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>
    <dir>$ROOT/usr/share/fonts</dir>
    <cachedir>$WORK/fontcache</cachedir>
</fontconfig>
FONTCONFIG
export FONTCONFIG_FILE=$WORK/fonts.conf
FF=(-hide_banner -nostdin -y -abort_on empty_output+empty_output_stream)
VSRC=(-f lavfi -i testsrc2=size=320x240:rate=25:duration=0.4)
ASRC=(-f lavfi -i sine=frequency=440:sample_rate=48000:duration=1)
failed=()

ff() {
    "$ROOT/ffmpeg" "${FF[@]}" "$@"
}

fp() {
    "$ROOT/ffprobe" -hide_banner "$@"
}

result() {
    if [[ $2 -eq 0 ]]; then
        echo "ok      $1"
    else
        echo "FEHLER  $1"
        failed+=("$1")
        tail -n 5 "$WORK/$1.log" | sed 's/^/    | /'
    fi
}

check() {
    local name=$1
    shift
    "$@" >"$WORK/$name.log" 2>&1
    result "$name" $?
}

expect() {
    local name=$1 pattern=$2
    shift 2
    "$@" >"$WORK/$name.log" 2>&1
    grep -Eq "$pattern" "$WORK/$name.log"
    result "$name" $?
}

reject() {
    local name=$1 pattern=$2
    shift 2
    "$@" >"$WORK/$name.log" 2>&1 && ! grep -Eq "$pattern" "$WORK/$name.log"
    result "$name" $?
}

pair() {
    local receive_url=$1 send_url=$2
    timeout "$WORST_CASE_SECONDS" "$ROOT/ffmpeg" "${FF[@]}" -f mpegts -i "$receive_url" -frames:v 5 -f null - &
    local receiver=$!
    while kill -0 "$receiver" 2>/dev/null; do
        ff -re -f lavfi -i testsrc2=size=320x240:rate=25:duration=2 -c:v mpeg2video -f mpegts "$send_url" \
            >/dev/null 2>&1 || sleep 1
    done
    wait "$receiver"
}

iconv_recode() {
    ff -sub_charenc ISO-8859-1 -i latin1.srt utf8.srt && grep -q $'Gr\xc3\xbc\xc3\x9fe' "$WORK/utf8.srt"
}

lcms2_embed() {
    ff "${VSRC[@]}" -vf setparams=color_primaries=bt709:color_trc=bt709:colorspace=bt709 \
        -flags2 icc_profiles -frames:v 1 -update 1 icc.png &&
        fp -show_frames icc.png | grep 'ICC profile' >/dev/null
}

x265_hdr10plus() {
    printf '[{"NumberOfWindows":1,"TargetedSystemDisplayMaximumLuminance":400,"LuminanceParameters":{"AverageRGB":100,"MaxScl0":1000,"MaxScl1":1000,"MaxScl2":1000,"PercentileLuminance":{"NumberOfPercentiles":0}}}]\n' >hdr10plus.json
    ff "${VSRC[@]}" -pix_fmt yuv420p10le -c:v libx265 -x265-params dhdr10-info=hdr10plus.json hdr10plus.hevc &&
        fp -show_frames hdr10plus.hevc | grep 'HDR Dynamic Metadata SMPTE2094-40' >/dev/null
}

rsvg_avif() {
    local red green blue alpha
    ff -f lavfi -i color=c=red:size=64x64 -frames:v 1 -c:v libaom-av1 red.avif || return
    printf '<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64"><image width="64" height="64" href="data:image/avif;base64,%s"/></svg>\n' \
        "$(base64 -w0 red.avif)" >avif.svg
    ff -c:v librsvg -i avif.svg -vf crop=1:1:32:32,format=rgba -f rawvideo avif.rgba || return
    read -r red green blue alpha < <(od -An -tu1 avif.rgba)
    echo "rgba $red $green $blue $alpha"
    ((red > 200 && green < 60 && blue < 60 && alpha == 255))
}

aribb24_decode() {
    echo "$ARIB_SHA256  $WORK/arib.ts" | sha256sum -c - || return
    # aribb24 1.0.3 reads depth-0 DRCS patterns as 2 bpp and overruns the unit: skip the DRCS unit, replace its glyph by "AB"
    for patch in 2b3:'\x3f' 2e8:'\x1b\x28\x4a\x0f\x41\x42'; do
        printf "${patch#*:}" | dd of="$WORK/arib.ts" bs=1 seek=$((16#${patch%%:*})) conv=notrunc status=none
    done
    ff -c:s libaribb24 -i arib.ts -map 0:s -c:s ass -f ass ab.ass && grep -q 'ＡＢ' "$WORK/ab.ass"
}

printf '1\n00:00:00,000 --> 00:00:01,000\nlibass\n' >"$WORK/sub.srt"
printf '1\n00:00:00,000 --> 00:00:01,000\nGr\xfc\xdfe\n' >"$WORK/latin1.srt"
printf '<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64"><circle cx="32" cy="32" r="16" fill="red"/></svg>\n' >"$WORK/img.svg"
{
    printf 'Vgm \x42\0\0\0\x10\x01\0\0\x99\x9e\x36\0\0\0\0\0\0\0\0\0\x3a\x11\0\0'
    head -c 36 /dev/zero
    printf '\x50\x90\x61\x3a\x11\x66'
} >"$WORK/tone.vgm"
{
    head -c 42 /dev/zero
    printf '\x00\x10\x00\x40\x00\x00\x00\x01'
    head -c 900 /dev/zero
    printf '\x01\x7f'
    head -c 128 /dev/zero
    printf 'M.K.\x01\xac\x10\x00'
    head -c 1020 /dev/zero
    printf '\x7f%.0s' {1..16}
    printf '\x80%.0s' {1..16}
} >"$WORK/tone.mod"
mkdir "$WORK/nobd"
for sample in hrtf.sofa:"$SOFA_SAMPLE" arib.ts:"$ARIB_SAMPLE" avs3.avs3:"$AVS3_SAMPLE" avs3_10bit.avs3:"$AVS3_10BIT_SAMPLE"; do
    curl -fsSL -o "$WORK/${sample%%:*}" "${sample#*:}"
done

check libaom-enc ff "${VSRC[@]}" -c:v libaom-av1 av1.mkv
check libaom-dec ff -c:v libaom-av1 -i av1.mkv -f null -
check libdav1d ff -c:v libdav1d -i av1.mkv -f null -
check librav1e ff "${VSRC[@]}" -c:v librav1e -f null -
check libsvtav1 ff "${VSRC[@]}" -c:v libsvtav1 -f null -
check libvvenc ff "${VSRC[@]}" -c:v libvvenc -f null -
check libx264 ff "${VSRC[@]}" -c:v libx264 -f null -
check libx264rgb ff "${VSRC[@]}" -c:v libx264rgb -f null -
check libx265 ff "${VSRC[@]}" -c:v libx265 -f null -
check libx265-alpha ff "${VSRC[@]}" -vf format=yuva420p -c:v libx265 -f null -
check libx265-hdr10plus x265_hdr10plus
check libkvazaar ff "${VSRC[@]}" -c:v libkvazaar -f null -
check libxavs2 ff "${VSRC[@]}" -c:v libxavs2 -f avs2 avs2.avs2
check libdavs2 ff -f avs2 -c:v libdavs2 -i avs2.avs2 -f null -
check libuavs3d ff -f avs3 -c:v libuavs3d -i avs3.avs3 -f null -
check libuavs3d-10bit ff -f avs3 -c:v libuavs3d -i avs3_10bit.avs3 -f null -
check libxeve ff -f lavfi -i testsrc2=size=320x240:rate=25:duration=2 -c:v libxeve -f evc evc.evc
check libxevd ff -f evc -c:v evc -i evc.evc -f null -
check libxvid ff "${VSRC[@]}" -c:v libxvid -f null -
check libtheora ff "${VSRC[@]}" -c:v libtheora -f null -
check libvpx-vp8-enc ff "${VSRC[@]}" -c:v libvpx vp8.webm
check libvpx-vp8-dec ff -c:v libvpx -i vp8.webm -f null -
check libvpx-vp9-enc ff "${VSRC[@]}" -c:v libvpx-vp9 vp9.webm
check libvpx-vp9-dec ff -c:v libvpx-vp9 -i vp9.webm -f null -
check libopenjpeg ff "${VSRC[@]}" -c:v libopenjpeg -frames:v 1 -update 1 image.jp2
check libwebp ff "${VSRC[@]}" -c:v libwebp -frames:v 1 image.webp
check libwebpmux ff "${VSRC[@]}" -c:v libwebp_anim anim.webp
check libjxl-enc ff "${VSRC[@]}" -c:v libjxl -frames:v 1 -update 1 image.jxl
check libjxl-dec ff -c:v libjxl -i image.jxl -f null -
check libjxl-anim-enc ff "${VSRC[@]}" -c:v libjxl_anim -f image2pipe anim.jxl
check libjxl-anim-dec ff -c:v libjxl_anim -i anim.jxl -f null -
check librsvg ff -c:v librsvg -i img.svg -f null -
check librsvg-avif rsvg_avif
check libsnappy ff "${VSRC[@]}" -c:v hap -compressor snappy hap.mov

check libfdk-aac-enc ff "${ASRC[@]}" -c:a libfdk_aac fdk.aac
check libfdk-aac-dec ff -c:a libfdk_aac -i fdk.aac -f null -
check libgsm-enc ff "${ASRC[@]}" -ar 8000 -c:a libgsm gsm.gsm
check libgsm-dec ff -c:a libgsm -i gsm.gsm -f null -
check libgsm-ms-enc ff "${ASRC[@]}" -ar 8000 -c:a libgsm_ms gsm_ms.wav
check libgsm-ms-dec ff -c:a libgsm_ms -i gsm_ms.wav -f null -
check libmp3lame ff "${ASRC[@]}" -c:a libmp3lame -f null -
check libshine ff "${ASRC[@]}" -c:a libshine -f null -
check libtwolame ff "${ASRC[@]}" -c:a libtwolame -f null -
check libopencore-amrnb-enc ff "${ASRC[@]}" -ar 8000 -c:a libopencore_amrnb -b:a 12.2k nb.amr
check libopencore-amrnb-dec ff -c:a libopencore_amrnb -i nb.amr -f null -
check libvo-amrwbenc ff "${ASRC[@]}" -ar 16000 -c:a libvo_amrwbenc -b:a 23.85k wb.amr
check libopencore-amrwb ff -c:a libopencore_amrwb -i wb.amr -f null -
check libopus-enc ff "${ASRC[@]}" -c:a libopus opus.ogg
check libopus-dec ff -c:a libopus -i opus.ogg -f null -
check libspeex-enc ff "${ASRC[@]}" -ar 16000 -c:a libspeex speex.ogg
check libspeex-dec ff -c:a libspeex -i speex.ogg -f null -
check libvorbis-enc ff "${ASRC[@]}" -c:a libvorbis vorbis.ogg
check libvorbis-dec ff -c:a libvorbis -i vorbis.ogg -f null -
check libgme ff -f libgme -i tone.vgm -t 0.1 -f null -
check libmodplug ff -f libmodplug -i tone.mod -t 1 -f null -

check libsoxr ff "${ASRC[@]}" -af aresample=resampler=soxr -ar 44100 -f null -
check librubberband ff "${ASRC[@]}" -af rubberband=tempo=1.5 -f null -
check libmysofa ff "${ASRC[@]}" -ac 2 -af sofalizer=sofa=hrtf.sofa -f null -
check libvidstab-detect ff "${VSRC[@]}" -vf vidstabdetect=result=vidstab.trf -f null -
check libvidstab-transform ff "${VSRC[@]}" -vf vidstabtransform=input=vidstab.trf -f null -
check libvmaf ff "${VSRC[@]}" "${VSRC[@]}" -lavfi libvmaf -f null -
check libzimg ff "${VSRC[@]}" -vf zscale=w=160:h=120 -f null -
reject libfreetype freetype ff "${ASRC[@]}" -lavfi "[0:a]showcqt=fontfile=$FONTFILE" -frames:v 1 -f null -
check libharfbuzz ff "${VSRC[@]}" -vf "drawtext=fontfile=$FONTFILE:text=harfbuzz" -f null -
check libfribidi ff "${VSRC[@]}" -vf "drawtext=fontfile=$FONTFILE:text=שלום" -f null -
check fontconfig ff "${VSRC[@]}" -vf "drawtext=font=DejaVu Sans:text=fontconfig" -f null -
check libass-subtitles ff "${VSRC[@]}" -vf subtitles=sub.srt -f null -
reject libunibreak "wasn't built with ASS_FEATURE_WRAP_UNICODE" ff "${VSRC[@]}" -vf subtitles=sub.srt:wrap_unicode=1 -f null -
check libass-prep ff -i sub.srt sub.ass
check libass-ass-filter ff "${VSRC[@]}" -vf ass=sub.ass -f null -
check libaribb24 aribb24_decode
check iconv iconv_recode
check lcms2-filter ff "${VSRC[@]}" -vf setparams=color_primaries=bt709:color_trc=bt709:colorspace=bt709,iccgen,iccdetect -f null -
check lcms2-encode lcms2_embed

check dash-prep ff "${VSRC[@]}" -c:v libx264 -f dash stream.mpd
check libxml2-dash ff -i stream.mpd -f null -
check openssl fp -ca_file "$ROOT/etc/ssl/cert.pem" -i https://github.com/favicon.ico
check libsrt pair "srt://127.0.0.1:9000?mode=listener" "srt://127.0.0.1:9000"
check libzmq pair zmq:tcp://127.0.0.1:5555 zmq:tcp://127.0.0.1:5555
check libzmq-zmq-filter ff "${VSRC[@]}" -vf "zmq=b='tcp\://127.0.0.1\:5556'" -f null -
check libzmq-azmq-filter ff "${ASRC[@]}" -af "azmq=b='tcp\://127.0.0.1\:5557'" -f null -
expect libssh 'Connection failed' fp sftp://127.0.0.1:1/none
expect librabbitmq 'Error connecting to server' fp amqp://127.0.0.1:1
expect librtmp 'failed to connect socket' fp rtmp://127.0.0.1:1/app/none
expect libbluray 'bd_open\(\) failed|BluRay disc not detected' fp "bluray:$WORK/nobd"

echo
if [[ ${#failed[@]} -eq 0 ]]; then
    echo "=== alle Tests ok"
    rm -rf "$WORK"
else
    echo "=== ${#failed[@]} fehlgeschlagen: ${failed[*]}"
    echo "=== Logs: $WORK"
    exit 1
fi
