part of 'add_prompts_bloc.dart';

enum UploadStatus {
  uploading, uploaded, failed,resourceAdded, initial
}

enum Resource1Status {
  initial, selected, failed, uploaded,
}
enum Resource2Status {
  initial, selected, failed, uploaded,
}

class AddPromptsInitial extends Equatable {
  final UploadStatus? uploadStatus;
  final Resource1Status resource1status;
  final Resource2Status resource2status;
  final String? side1selectedMediaType;
  final String? side2selectedMediaType;
  final String? side1ResourceUrl;
  final String? side2ResourceUrl;
  final String? side1Id;
  final String? side2Id;
  final bool? showResource;

  AddPromptsInitial({
    this.showResource,
    this.uploadStatus,
    this.side1selectedMediaType = "Text",
    this.side2selectedMediaType = "Text",
    this.side1ResourceUrl = '',
    this.side2ResourceUrl = '',
    this.side1Id = '',
    this.side2Id = '',
    this.resource1status = Resource1Status.initial,
    this.resource2status = Resource2Status.initial,
  });

  // CopyWith method
  AddPromptsInitial copyWith({
    bool? showResource,
    UploadStatus? uploadStatus,
    String? side1selectedMediaType,
    String? side2selectedMediaType,
    String? side1ResourceUrl,
    String? side2ResourceUrl,
    String? side1Id,
    String? side2Id,
    Resource1Status? resource1status,
    Resource2Status? resource2status,
  }) {
    //print('Old: showResource-${this.showResource.toString()} ${this.uploadStatus.toString()} MediaType1-${this.side1selectedMediaType} URL1-${this.side1ResourceUrl} ID1-${this.side1Id} MediaType2-${this.side2selectedMediaType} URL2-${this.side2ResourceUrl} ID2-${this.side2Id}');
    //print('New: showResource-${showResource.toString()} ${uploadStatus.toString()} MediaType1-${side1selectedMediaType} URL1-${side1ResourceUrl} ID1-${side1Id} MediaType2-${side2selectedMediaType} URL2-${side2ResourceUrl} ID2-${side2Id}');
    return AddPromptsInitial(
      showResource: showResource ?? this.showResource,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      side1Id: side1Id ?? this.side1Id,
      side2Id: side2Id ?? this.side2Id,
      side1selectedMediaType: side1selectedMediaType ?? this.side1selectedMediaType,
      side2selectedMediaType: side2selectedMediaType ?? this.side2selectedMediaType,
      side1ResourceUrl: (side1ResourceUrl != '') ? side1ResourceUrl ?? this.side1ResourceUrl : this.side1ResourceUrl,
      side2ResourceUrl: (side2ResourceUrl != '') ? side2ResourceUrl ?? this.side2ResourceUrl: this.side2ResourceUrl,
      resource1status: resource1status ?? this.resource1status,
      resource2status: resource2status ?? this.resource2status,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [side1ResourceUrl, side2ResourceUrl, showResource, uploadStatus, side1selectedMediaType, side2selectedMediaType, side1Id, side2Id, resource1status, resource2status];
}


