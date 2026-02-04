import 'user_model.dart';

class Objective {
  final String id;
  final String title;
  final String description;
  final User assignedTo;
  final User assignedBy;
  final String? teamId;
  final String? departmentId;
  final ObjectiveStatus status;
  final ObjectivePriority priority;
  final int progress;
  final DateTime startDate;
  final DateTime dueDate;
  final DateTime? completedAt;
  final List<ObjectiveComment> comments;
  final List<FileAttachment> files;
  final List<SubTask> subTasks;
  final List<String> links;
  final String? notes;
  final String? blockReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  Objective({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.assignedBy,
    this.teamId,
    this.departmentId,
    required this.status,
    required this.priority,
    required this.progress,
    required this.startDate,
    required this.dueDate,
    this.completedAt,
    this.comments = const [],
    this.files = const [],
    this.subTasks = const [],
    this.links = const [],
    this.notes,
    this.blockReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Objective.fromJson(Map<String, dynamic> json) {
    User parseUser(dynamic userJson) {
      if (userJson == null) {
        return User(
          id: '',
          firstname: 'Utilisateur',
          lastname: 'Inconnu',
          email: '',
          role: UserRole.employee,
          active: false,
        );
      }
      if (userJson is String) {
        return User(
          id: userJson,
          firstname: 'Utilisateur',
          lastname: 'Inconnu',
          email: '',
          role: UserRole.employee,
          active: false,
        );
      }
      if (userJson is Map<String, dynamic>) {
        return User.fromJson(userJson);
      }
      return User(
        id: '',
        firstname: 'Utilisateur',
        lastname: 'Inconnu',
        email: '',
        role: UserRole.employee,
        active: false,
      );
    }

    DateTime parseDate(dynamic dateJson) {
      if (dateJson == null) return DateTime.now();
      try {
        return DateTime.parse(dateJson.toString());
      } catch (e) {
        return DateTime.now();
      }
    }

    return Objective(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      assignedTo: parseUser(json['assignedTo']),
      assignedBy: parseUser(json['assignedBy']),
      teamId: json['team']?.toString(),
      departmentId: json['department']?.toString(),
      status: ObjectiveStatus.fromString((json['status'] ?? 'todo').toString()),
      priority: ObjectivePriority.fromString((json['priority'] ?? 'medium').toString()),
      progress: json['progress'] is num ? (json['progress'] as num).toInt() : 0,
      startDate: parseDate(json['startDate']),
      dueDate: parseDate(json['dueDate']),
      completedAt: json['completedAt'] != null 
          ? DateTime.tryParse(json['completedAt'].toString()) 
          : null,
      comments: (json['comments'] as List<dynamic>?)
          ?.map((c) => ObjectiveComment.fromJson(c is Map<String, dynamic> ? c : {}))
          .toList() ?? [],
      files: (json['files'] as List<dynamic>?)
          ?.map((f) => FileAttachment.fromJson(f is Map<String, dynamic> ? f : {}))
          .toList() ?? [],
      subTasks: (json['subTasks'] as List<dynamic>?)
          ?.map((s) => SubTask.fromJson(s is Map<String, dynamic> ? s : {}))
          .toList() ?? [],
      links: (json['links'] as List<dynamic>?)
          ?.map((l) => l.toString())
          .toList() ?? [],
      notes: json['notes']?.toString(),
      blockReason: json['blockReason']?.toString(),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assignedTo': assignedTo.id,
      'assignedBy': assignedBy.id,
      'team': teamId,
      'department': departmentId,
      'status': status.value,
      'priority': priority.value,
      'progress': progress,
      'startDate': startDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'links': links,
      'notes': notes,
      'blockReason': blockReason,
    };
  }

  Objective copyWith({
    String? title,
    String? description,
    ObjectiveStatus? status,
    ObjectivePriority? priority,
    int? progress,
    DateTime? startDate,
    DateTime? dueDate,
    DateTime? completedAt,
    List<ObjectiveComment>? comments,
    List<FileAttachment>? files,
    List<SubTask>? subTasks,
    List<String>? links,
    String? notes,
    String? blockReason,
  }) {
    return Objective(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedTo: assignedTo,
      assignedBy: assignedBy,
      teamId: teamId,
      departmentId: departmentId,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      progress: progress ?? this.progress,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      comments: comments ?? this.comments,
      files: files ?? this.files,
      subTasks: subTasks ?? this.subTasks,
      links: links ?? this.links,
      notes: notes ?? this.notes,
      blockReason: blockReason ?? this.blockReason,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  bool get isOverdue => DateTime.now().isAfter(dueDate) && status != ObjectiveStatus.completed;
  bool get isCompleted => status == ObjectiveStatus.completed;
  bool get isBlocked => status == ObjectiveStatus.blocked;
  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;
}

enum ObjectiveStatus {
  todo('todo', 'À faire'),
  inProgress('in_progress', 'En cours'),
  completed('completed', 'Terminé'),
  blocked('blocked', 'Bloqué');

  final String value;
  final String label;

  const ObjectiveStatus(this.value, this.label);

  static ObjectiveStatus fromString(String value) {
    return ObjectiveStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ObjectiveStatus.todo,
    );
  }
}

enum ObjectivePriority {
  low('low', 'Basse'),
  medium('medium', 'Moyenne'),
  high('high', 'Haute'),
  urgent('urgent', 'Urgente');

  final String value;
  final String label;

  const ObjectivePriority(this.value, this.label);

  static ObjectivePriority fromString(String value) {
    return ObjectivePriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => ObjectivePriority.medium,
    );
  }
}

class ObjectiveComment {
  final String id;
  final User user;
  final String text;
  final DateTime createdAt;

  ObjectiveComment({
    required this.id,
    required this.user,
    required this.text,
    required this.createdAt,
  });

  factory ObjectiveComment.fromJson(Map<String, dynamic> json) {
    return ObjectiveComment(
      id: json['_id'] ?? json['id'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
      text: json['text'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class FileAttachment {
  final String id;
  final String name;
  final String url;
  final String mimeType;
  final int size;
  final DateTime uploadedAt;

  FileAttachment({
    required this.id,
    required this.name,
    required this.url,
    required this.mimeType,
    required this.size,
    required this.uploadedAt,
  });

  factory FileAttachment.fromJson(Map<String, dynamic> json) {
    return FileAttachment(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      mimeType: json['mimeType'] ?? 'application/octet-stream',
      size: json['size'] ?? 0,
      uploadedAt: DateTime.parse(json['uploadedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'mimeType': mimeType,
      'size': size,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  String get sizeFormatted {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class SubTask {
  final String id;
  final String title;
  final bool isCompleted;

  SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  SubTask copyWith({
    String? title,
    bool? isCompleted,
  }) {
    return SubTask(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
