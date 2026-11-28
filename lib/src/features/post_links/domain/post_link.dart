class PostLink {
  const PostLink({required this.code, required this.url, this.appUrl});

  final String code;
  final Uri url;
  final Uri? appUrl;
}

abstract interface class PostLinkRepository {
  Future<PostLink> postLink(String postId);

  Future<String?> resolvePostLink(String code);
}

final _codePattern = RegExp(r'^[A-Za-z0-9]{10}$');

String? communityPostLinkCode(Uri uri) {
  final scheme = uri.scheme.toLowerCase();
  final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  final String? code;
  if (scheme == 'http' || scheme == 'https') {
    code = segments.length == 2 && segments.first == 'p' ? segments.last : null;
  } else if (RegExp(r'^[a-z][a-z0-9+.-]{1,30}$').hasMatch(scheme) && scheme != 'file') {
    code = uri.host == 'p' && segments.length == 1
        ? segments.first
        : uri.host.isEmpty && segments.length == 2 && segments.first == 'p'
        ? segments.last
        : null;
  } else {
    code = null;
  }
  return code != null && _codePattern.hasMatch(code) ? code : null;
}
