import 'package:flutter/material.dart';

class AnimatedImage extends StatefulWidget {
  final ImageProvider image;
  final double? width;
  final double? height;
  final FilterQuality filterQuality;

  const AnimatedImage(
      {required this.image,
      this.width,
      this.height,
      this.filterQuality = FilterQuality.medium,
      super.key});

  @override
  State<StatefulWidget> createState() => _AnimatedImageState();
}

class _AnimatedImageState extends State<AnimatedImage> {
  ImageInfo? _imageInfo;
  ImageStream? _imageStream;
  Object? _lastException;
  bool _isListeningToStream = false;
  ImageStreamListener? _imageStreamListener;
  ImageChunkEvent? _imageChunkEvent;
  late DisposableBuildContext<State<AnimatedImage>> _scrollAwareContext;

  @override
  void initState() {
    super.initState();
    _scrollAwareContext = DisposableBuildContext<State<AnimatedImage>>(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImage();
    if (TickerMode.of(context)) {
      _listenToStream();
    } else {
      _stopListenToStream();
    }
  }

  @override
  void dispose() {
    _stopListenToStream();
    _scrollAwareContext.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget result = const Center();
    if (_imageInfo != null) {
      result = RawImage(
          image: _imageInfo?.image,
          width: widget.width,
          height: widget.height,
          filterQuality: widget.filterQuality);
    } else if (_lastException != null) {
      result = const Center(child: Icon(Icons.error));
    } else {
      return SizedBox(
          width: widget.width,
          height: widget.height ?? (widget.width! * 1.2),
          child: Center(
              child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      backgroundColor: Colors.white24,
                      strokeWidth: 3,
                      value: _imageChunkEvent != null
                          ? _imageChunkEvent!.cumulativeBytesLoaded /
                              _imageChunkEvent!.expectedTotalBytes!
                          : 0))));
    }
    return AnimatedSwitcher(
        duration: const Duration(microseconds: 150),
        reverseDuration: const Duration(microseconds: 150),
        child: result);
  }

  void _resolveImage() {
    final ScrollAwareImageProvider provider = ScrollAwareImageProvider(
        context: _scrollAwareContext, imageProvider: widget.image);
    final ImageStream newStream =
        provider.resolve(createLocalImageConfiguration(context));
    if (_imageStream?.key == newStream.key) return;
    if (_isListeningToStream) _imageStream!.removeListener(_getListener());
    _imageStream = newStream;
    if (_isListeningToStream) _imageStream!.addListener(_getListener());
  }

  void _listenToStream() {
    if (_isListeningToStream) return;
    _imageStream!.addListener(_getListener());
    _isListeningToStream = true;
  }

  void _stopListenToStream() {
    if (!_isListeningToStream) return;
    _imageStream!.completer!.keepAlive();
    _imageStream!.removeListener(_getListener());
    _isListeningToStream = true;
  }

  ImageStreamListener _getListener() {
    _imageStreamListener ??= ImageStreamListener(
        (imageInfo, synchronousCall) {
          setState(() {
            _replaceImage(imageInfo);
            _lastException = null;
          });
        },
        onChunk: (event) => setState(() {
              _imageChunkEvent = event;
            }),
        onError: (Object error, StackTrace? stackTrace) {
          setState(() {
            _lastException = error;
          });
        });
    return _imageStreamListener!;
  }

  void _replaceImage(ImageInfo imageInfo) {
    _imageInfo = imageInfo;
  }
}
