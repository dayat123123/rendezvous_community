Map<String, dynamic> serverPolicy({bool videos = true}) => {
  'documents': {
    'enabled': true,
    'bucket': 'cs-documents',
    'max_bytes': 10485760,
    'formats': [
      {'code': 'pdf', 'mime': 'application/pdf', 'ext': 'pdf'},
      {
        'code': 'docx',
        'mime': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'ext': 'docx',
      },
      {'code': 'xlsx', 'mime': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'ext': 'xlsx'},
      {
        'code': 'pptx',
        'mime': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
        'ext': 'pptx',
      },
      {'code': 'txt', 'mime': 'text/plain', 'ext': 'txt'},
      {'code': 'csv', 'mime': 'text/csv', 'ext': 'csv'},
    ],
  },
  'images': {
    'enabled': true,
    'bucket': 'attachments',
    'max_bytes': 5242880,
    'formats': [
      {'code': 'jpeg', 'mime': 'image/jpeg', 'ext': 'jpg'},
      {'code': 'png', 'mime': 'image/png', 'ext': 'png'},
      {'code': 'webp', 'mime': 'image/webp', 'ext': 'webp'},
      {'code': 'gif', 'mime': 'image/gif', 'ext': 'gif'},
    ],
  },
  'videos': {
    'enabled': videos,
    'bucket': 'cs-videos',
    'max_bytes': 26214400,
    'max_seconds': 120,
    'formats': [
      {'code': 'mp4', 'mime': 'video/mp4', 'ext': 'mp4'},
      {'code': 'mov', 'mime': 'video/quicktime', 'ext': 'mov'},
      {'code': 'webm', 'mime': 'video/webm', 'ext': 'webm'},
    ],
  },
};
