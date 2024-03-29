import 'package:get/get.dart';

import '../../common/entities/entities.dart';

class GetJobState {
  Job? job;
  int? currentId;
  StartJobResponse? startJobResponse;

  final keyWordHintId = 'search-key-hint';

  final Rx<JobStatus> _statusJob = JobStatus.none.obs;

  JobStatus get jobStatus => _statusJob.value;

  Stream<JobStatus> get statusJobStream => _statusJob.stream;

  setJobStatus(JobStatus value) => _statusJob.value = value;

  final RxString _title = ''.obs;

  String get title => _title.value;

  setTitle(String value) => _title.value = value;

  final RxString _tip = ''.obs;

  String get tip => _tip.value;

  setTip(String value) => _tip.value = value;

  bool firstResultHint = true;

  final RxnInt _fakeCount = RxnInt(null);

  int? get fakeCount => _fakeCount.value;

  setFakeCount(int? value) => _fakeCount.value = value;

  final RxBool _showCopyKeyword = RxBool(true);

  bool get showCopyKeyword => _showCopyKeyword.value;

  setShowCopyKeyword(bool value) => _showCopyKeyword.value = value;
}

enum Event {
  startError,
  timeOut,
  finishJob,
}
