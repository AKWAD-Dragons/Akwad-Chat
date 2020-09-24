part of 'models/Room.dart';

class SendMessageTask {
  Map<String, _SingleUploadTask> _taskMap;
  List<ChatAttachment> _attachments = [];
  List<Function(List<ChatAttachment>)> _onCompleteCallBacks = [];

  List<Function(SendMessageTask)> _onProgressCallBacks = [];

  int _count = 0;
  int _totalSize = 0;

  Map<String, TaskUpdateEvent> _totalDone = {};

  int get totalSize => _totalSize;
  int get totalDone => _totalDone.values
      .fold<int>(0, (int value, TaskUpdateEvent event) => event._progress);

  SendMessageTask._(this._taskMap) {
    _taskMap.forEach((String key, _SingleUploadTask value) {
      StreamSubscription sub;
      if (value._attachment != null) {
        _totalSize += value._total;
        _count++;
        sub = value.events.listen((_TaskEvent event) {
          if (event is TaskUpdateEvent) {
            _totalDone[key] = event;
            _callOnProgressCallBacks();
          }
          if (event is TaskCompletedEvent) {
            _attachments.add(event.uploadedAttachment);
            sub.cancel();
            if (_attachments.length == _count &&
                _onCompleteCallBacks.isNotEmpty) {
              _callOnCompleteCallBacks(_attachments);
            }
          }
        });
      }
    });
  }

  void startAllTasks(){
    _taskMap.values.forEach((_SingleUploadTask _singleUploadTask) {
      _singleUploadTask.start();
    });
  }

  void addOnCompleteListener(
      Function(List<ChatAttachment>) onCompleteCallBack) {
    _onCompleteCallBacks.add(onCompleteCallBack);
  }

  void addOnProgressListener(
      Function(SendMessageTask task) onProgressCallBack) {
    _onProgressCallBacks.add(onProgressCallBack);
  }

  void _callOnCompleteCallBacks(List<ChatAttachment> attachments) {
    _onCompleteCallBacks.forEach(
        (Function(List<ChatAttachment>) callback) => callback(attachments));
  }

  void _callOnProgressCallBacks() {
    _onProgressCallBacks
        .forEach((Function(SendMessageTask) callback) => callback(this));
  }

  _SingleUploadTask getTaskByKey(String key) {
    return _taskMap[key];
  }
}

class _SingleUploadTask {
  int _total;
  int _progress;
  ChatAttachment _attachment;
  String _path;
  final StorageReference storageReference = FirebaseStorage().ref();
  StreamSubscription _sub;

  int get total => _total;

  int get progress => _progress;

  StreamController<_TaskEvent> _controller =
      StreamController<_TaskEvent>.broadcast();

  Stream<_TaskEvent> get events => _controller.stream;

  _SingleUploadTask._(this._attachment, this._path){
    _total = this._attachment?.file?.lengthSync()??0;
  }

  void start(){
    StorageUploadTask task = storageReference
        .child(_path)
        .putFile(_attachment.file);
    _sub = task.events.listen((StorageTaskEvent event) async {
      if(event.type == StorageTaskEventType.progress){
        _updateProgress(event.snapshot.bytesTransferred);
      }
      if (event.type == StorageTaskEventType.success) {
        _attachment.file = null;
        _attachment.fileLink = await event.snapshot.ref.getDownloadURL();
        _setCompleted(_attachment);
        _sub.cancel();
      }
      if (event.type == StorageTaskEventType.failure) {
        _sub.cancel();
      }
    });
  }

  void _setCompleted(ChatAttachment uploadedAttachment) {
    _controller.add(TaskCompletedEvent(uploadedAttachment));
    _sub.cancel();
  }

  void _updateProgress(int updatedProgress) {
    _progress = updatedProgress;
    _controller.add(TaskUpdateEvent(_progress, _total));
  }
}

abstract class _TaskEvent {}

class TaskUpdateEvent extends _TaskEvent {
  int _total;
  int _progress;

  int get total => _total;

  int get progress => _progress;

  TaskUpdateEvent(this._progress, this._total);
}

class TaskCompletedEvent extends _TaskEvent {
  ChatAttachment _uploadedAttachment;

  ChatAttachment get uploadedAttachment => _uploadedAttachment;

  TaskCompletedEvent(this._uploadedAttachment);
}
