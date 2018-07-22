#include <assert.h>
#include <stdio.h>

#include <libavformat/avformat.h>

enum {target_stream = 2};

int main(int argc, char ** argv) {
	assert(argc == 2);

	av_register_all();

	AVFormatContext *s = NULL;
	int ret = avformat_open_input(&s, argv[1], NULL, NULL);
	if (ret < 0) {
		printf("%s\n", av_err2str(ret));
		abort();
	}

	AVPacket pkt = {.size = 0, .data = NULL};
	av_init_packet(&pkt);
	while(!av_read_frame(s, &pkt)) {
		if (pkt.stream_index != target_stream) continue;
		AVRational tb = s->streams[target_stream]->time_base;
		printf(
			"%g --> %g\n",
			(double)pkt.pts / tb.den * tb.num,
			(double)(pkt.pts+pkt.duration) / tb.den * tb.num
		);
		printf("%*s\n", pkt.size, (const char*)pkt.data);
	}

	avformat_close_input(&s);
	return 0;
}
