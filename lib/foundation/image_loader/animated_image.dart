import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimatedImage extends StatefulWidget {
  final ImageProvider image;
  final FilterQuality filterQuality;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const AnimatedImage(
      {required this.image,
      this.filterQuality = FilterQuality.medium,
      this.width,
      this.height,
      this.fit,
      super.key});

  @override
  State<StatefulWidget> createState() => _AnimatedImageState();
}

class _AnimatedImageState extends State<AnimatedImage> {
  ImageInfo? _imageInfo;
  ImageStream? _imageStream;
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
    _listenToStream();
  }

  @override
  Widget build(BuildContext context) {
    return RawImage(
      image: _imageInfo?.image,
      width: widget.width,
      height: widget.height,
      filterQuality: widget.filterQuality,
    );
  }

  void _resolveImage() {
    final ScrollAwareImageProvider provider = ScrollAwareImageProvider(
        context: _scrollAwareContext, imageProvider: widget.image);
    final ImageStream stream =
        provider.resolve(createLocalImageConfiguration(context));
    _updateSourceStream(stream);
  }

  void _updateSourceStream(ImageStream stream) {
    _imageStream = stream;
  }

  void _listenToStream() {
    _imageStream!.addListener(_getListener());
  }

  ImageStreamListener _getListener() {
    return ImageStreamListener((imageInfo, synchronousCall) {
      setState(() {
        _replaceImage(imageInfo);
      });
    });
  }

  void _replaceImage(ImageInfo imageInfo) {
    _imageInfo = imageInfo;
  }
}
