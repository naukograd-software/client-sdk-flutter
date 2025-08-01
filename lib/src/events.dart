// Copyright 2024 LiveKit, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'core/engine.dart';
import 'core/room.dart';
import 'core/signal_client.dart';
import 'participant/local.dart';
import 'participant/participant.dart';
import 'participant/remote.dart';
import 'publication/local.dart';
import 'publication/remote.dart';
import 'publication/track_publication.dart';
import 'stats/stats.dart';
import 'track/processor.dart';
import 'track/track.dart';
import 'types/other.dart';
import 'types/participant_permissions.dart';
import 'types/transcription_segment.dart';

/// Base type for all LiveKit events.
mixin LiveKitEvent {}

/// Base type for all [Room] events.
mixin RoomEvent implements LiveKitEvent {}

/// Base type for all [Participant] events.
mixin ParticipantEvent implements LiveKitEvent {}

/// Base type for all [Track] events.
mixin TrackEvent implements LiveKitEvent {}

/// Base type for all [Engine] events.
mixin EngineEvent implements LiveKitEvent {}

/// Base type for all [SignalClient] events.
mixin SignalEvent implements LiveKitEvent {}

class RoomConnectedEvent with RoomEvent {
  final Room room;
  final String? metadata;
  const RoomConnectedEvent({
    required this.room,
    required this.metadata,
  });

  @override
  String toString() => '${runtimeType}(room: ${room})';
}

/// When the connection to the server has been interrupted and it's attempting
/// to reconnect.
/// Emitted by [Room].
class RoomReconnectingEvent with RoomEvent {
  const RoomReconnectingEvent();

  @override
  String toString() => '${runtimeType}()';
}

/// report the number of attempts to reconnect to the room.
class RoomAttemptReconnectEvent with RoomEvent {
  final int attempt;
  final int maxAttemptsRetry;
  final int nextRetryDelaysInMs;
  const RoomAttemptReconnectEvent({
    required this.attempt,
    required this.maxAttemptsRetry,
    required this.nextRetryDelaysInMs,
  });

  @override
  String toString() => '${runtimeType}()';
}

/// Connection to room is re-established. All existing state is preserved.
/// Emitted by [Room].
class RoomReconnectedEvent with RoomEvent {
  const RoomReconnectedEvent();

  @override
  String toString() => '${runtimeType}()';
}

/// Disconnected from the room
/// Emitted by [Room].
class RoomDisconnectedEvent with RoomEvent {
  DisconnectReason? reason;
  RoomDisconnectedEvent({
    this.reason,
  });

  @override
  String toString() => '${runtimeType}($reason)';
}

/// Room metadata has changed.
/// Emitted by [Room].
class RoomMetadataChangedEvent with RoomEvent {
  final String? metadata;

  const RoomMetadataChangedEvent({
    required this.metadata,
  });

  @override
  String toString() => '${runtimeType}()';
}

/// Participant's attributes have changed.
/// Emitted by [Room].
class ParticipantAttributesChanged with RoomEvent, ParticipantEvent {
  final Participant participant;
  final Map<String, String> attributes;

  const ParticipantAttributesChanged({
    required this.participant,
    required this.attributes,
  });

  @override
  String toString() => '${runtimeType}(participant: ${participant})';
}

/// Room recording status has changed.
/// Emitted by [Room].
class RoomRecordingStatusChanged with RoomEvent {
  final bool activeRecording;

  const RoomRecordingStatusChanged({
    required this.activeRecording,
  });

  @override
  String toString() => '${runtimeType}(activeRecording = $activeRecording)';
}

/// When a new [RemoteParticipant] joins *after* the current participant has connected
/// It will not fire for participants that are already in the room
/// Emitted by [Room].
class ParticipantConnectedEvent with RoomEvent {
  final RemoteParticipant participant;

  const ParticipantConnectedEvent({
    required this.participant,
  });

  @override
  String toString() => '${runtimeType}(participant: ${participant})';
}

/// When a [RemoteParticipant] leaves the room
/// Emitted by [Room].
class ParticipantDisconnectedEvent with RoomEvent {
  final RemoteParticipant participant;
  const ParticipantDisconnectedEvent({
    required this.participant,
  });

  @override
  String toString() => '${runtimeType}(participant: ${participant})';
}

/// Active speakers changed. List of speakers are ordered by their audio level.
/// loudest speakers first. This will include the [LocalParticipant] too.
class ActiveSpeakersChangedEvent with RoomEvent {
  final List<Participant> speakers;
  const ActiveSpeakersChangedEvent({
    required this.speakers,
  });

  @override
  String toString() => '${runtimeType}'
      '(speakers: ${speakers.map((e) => e.toString()).join(', ')})';
}

/// When a new [Track] is published to [Room] *after* the current participant has
/// joined. It will not fire for tracks that are already published.
/// Emitted by [Room] and [RemoteParticipant].
class TrackPublishedEvent with RoomEvent, ParticipantEvent {
  final RemoteParticipant participant;
  final RemoteTrackPublication publication;
  const TrackPublishedEvent({
    required this.participant,
    required this.publication,
  });

  @override
  String toString() => '${runtimeType}'
      '(participant: ${participant}, publication: ${publication})';
}

/// The participant has unpublished one of their [Track].
/// Emitted by [Room] and [RemoteParticipant].
class TrackUnpublishedEvent with RoomEvent, ParticipantEvent {
  final RemoteParticipant participant;
  final RemoteTrackPublication publication;
  const TrackUnpublishedEvent({
    required this.participant,
    required this.publication,
  });

  @override
  String toString() => '${runtimeType}'
      '(participant: ${participant}, publication: ${publication})';
}

/// When the local participant publishes a new [Track] to the room.
/// Emitted by [Room] and [LocalParticipant].
class LocalTrackPublishedEvent with RoomEvent, ParticipantEvent {
  final LocalParticipant participant;
  final LocalTrackPublication publication;
  const LocalTrackPublishedEvent({
    required this.participant,
    required this.publication,
  });

  @override
  String toString() => '${runtimeType}'
      '(participant: ${participant}, publication: ${publication})';
}

class LocalTrackSubscribedEvent with RoomEvent, ParticipantEvent {
  final String trackSid;
  const LocalTrackSubscribedEvent({
    required this.trackSid,
  });

  @override
  String toString() => '${runtimeType}'
      '(trakSid: ${trackSid}})';
}

/// The local participant has unpublished one of their [Track].
/// Emitted by [Room] and [LocalParticipant].
class LocalTrackUnpublishedEvent with RoomEvent, ParticipantEvent {
  final LocalParticipant participant;
  final LocalTrackPublication publication;
  const LocalTrackUnpublishedEvent({
    required this.participant,
    required this.publication,
  });

  @override
  String toString() => '${runtimeType}'
      '(participant: ${participant}, publication: ${publication})';
}

/// [LocalParticipant] has subscribed to a new track published by a
/// [RemoteParticipant].
/// Emitted by [Room] and [RemoteParticipant].
class TrackSubscribedEvent with RoomEvent, ParticipantEvent {
  final RemoteParticipant participant;
  final RemoteTrackPublication publication;
  final Track track;
  const TrackSubscribedEvent({
    required this.participant,
    required this.publication,
    required this.track,
  });

  @override
  String toString() => '${runtimeType}'
      '(participant: ${participant}, publication: ${publication}, '
      'track: ${track})';
}

/// An error has occured during track subscription.
/// Emitted by [Room] and [RemoteParticipant].
class TrackSubscriptionExceptionEvent with RoomEvent, ParticipantEvent {
  final RemoteParticipant? participant;
  final String? sid;
  final TrackSubscribeFailReason reason;
  const TrackSubscriptionExceptionEvent({
    this.participant,
    this.sid,
    required this.reason,
  });
}

/// The [LocalParticipant] has unsubscribed from a track published by a
/// [RemoteParticipant]. This event is fired when the track was unpublished.
/// Emitted by [Room] and [RemoteParticipant].
class TrackUnsubscribedEvent with RoomEvent, ParticipantEvent {
  final RemoteParticipant participant;
  final RemoteTrackPublication publication;
  final Track track;
  const TrackUnsubscribedEvent({
    required this.participant,
    required this.publication,
    required this.track,
  });

  @override
  String toString() => '${runtimeType}'
      '(participant: ${participant}, publication: ${publication}, '
      'track: ${track})';
}

/// A Participant has muted one of the track.
/// Emitted by [RemoteParticipant] and [LocalParticipant].
class TrackMutedEvent with RoomEvent, ParticipantEvent {
  final Participant participant;
  final TrackPublication publication;
  const TrackMutedEvent({
    required this.participant,
    required this.publication,
  });

  @override
  String toString() => '${runtimeType}'
      '(participant: ${participant}, publication: ${publication})';
}

/// This participant has unmuted one of their tracks
/// Emitted by [RemoteParticipant] and [LocalParticipant].
class TrackUnmutedEvent with RoomEvent, ParticipantEvent {
  final Participant participant;
  final TrackPublication publication;
  const TrackUnmutedEvent({
    required this.participant,
    required this.publication,
  });

  @override
  String toString() => '${runtimeType}'
      '(participant: ${participant}, publication: ${publication})';
}

/// The [StreamState] on the [RemoteTrackPublication] has updated by the server.
/// See [RemoteTrackPublication.streamState] for more information.
/// Emitted by [Room] and [RemoteParticipant].
class TrackStreamStateUpdatedEvent with RoomEvent, ParticipantEvent {
  final RemoteParticipant participant;
  final RemoteTrackPublication publication;
  final StreamState streamState;
  const TrackStreamStateUpdatedEvent({
    required this.participant,
    required this.publication,
    required this.streamState,
  });

  @override
  String toString() => '${runtimeType}'
      '(participant: ${participant}, publication: ${publication}, '
      'streamState: ${streamState})';
}

/// Participant metadata is a simple way for app-specific state to be pushed to
/// all users. When RoomService.UpdateParticipantMetadata is called to change a
/// [Participant]'s state, *all* [Participant]s in the room will fire this event.
/// Emitted by [Room] and [Participant].
class ParticipantMetadataUpdatedEvent with RoomEvent, ParticipantEvent {
  final Participant participant;
  final String metadata;
  const ParticipantMetadataUpdatedEvent({
    required this.participant,
    required this.metadata,
  });

  @override
  String toString() => '${runtimeType}(participant: ${participant})';
}

/// [Pariticpant]'s [ConnectionQuality] has updated.
/// Emitted by [Room] and [Participant].
class ParticipantConnectionQualityUpdatedEvent
    with RoomEvent, ParticipantEvent {
  final Participant participant;
  final ConnectionQuality connectionQuality;
  const ParticipantConnectionQualityUpdatedEvent({
    required this.participant,
    required this.connectionQuality,
  });

  @override
  String toString() => '${runtimeType}'
      '(participant: ${participant}, connectionQuality: ${connectionQuality})';
}

/// Data received from  [RemoteParticipant].
/// Data packets provides the ability to use LiveKit to send/receive arbitrary
/// payloads.
/// Emitted by [Room] and [RemoteParticipant].
class DataReceivedEvent with RoomEvent, ParticipantEvent {
  /// Sender of the data. This may be null if data is sent from Server API.
  final RemoteParticipant? participant;
  final List<int> data;
  final String? topic;
  const DataReceivedEvent({
    required this.participant,
    required this.data,
    required this.topic,
  });

  @override
  String toString() => '${runtimeType}'
      '(participant: ${participant}, data: ${data})';
}

/// The participant's isSpeaking property has changed
/// Emitted by [Participant].
class SpeakingChangedEvent with ParticipantEvent {
  final Participant participant;
  final bool speaking;
  const SpeakingChangedEvent({
    required this.participant,
    required this.speaking,
  });

  @override
  String toString() => '${runtimeType}'
      '(participant: ${participant}, speaking: ${speaking})';
}

/// One of subscribed tracks have changed its permissions for the current
/// participant. If permission was revoked, then the track will no longer
/// be subscribed. If permission was granted, a TrackSubscribed event will
/// be emitted.
class TrackSubscriptionPermissionChangedEvent with RoomEvent, ParticipantEvent {
  final Participant participant;
  final RemoteTrackPublication publication;
  final TrackSubscriptionState state;
  const TrackSubscriptionPermissionChangedEvent({
    required this.participant,
    required this.publication,
    required this.state,
  });

  @override
  String toString() => '${runtimeType}'
      '(participant: ${participant}, publication: ${publication}, '
      'state: ${state})';
}

/// The [ParticipantPermissions] updated for the [Participant].
/// Currently, only for [LocalParticipant].
/// Emitted by [Room] and [LocalParticipant].
class ParticipantPermissionsUpdatedEvent with RoomEvent, ParticipantEvent {
  final Participant participant;
  final ParticipantPermissions permissions;
  final ParticipantPermissions oldPermissions;
  const ParticipantPermissionsUpdatedEvent({
    required this.participant,
    required this.permissions,
    required this.oldPermissions,
  });

  @override
  String toString() => '${runtimeType}'
      '(participant: ${participant}, permissions: ${permissions})';
}

/// Transcription event received from the server.
class TranscriptionEvent with RoomEvent, ParticipantEvent {
  final Participant participant;
  final TrackPublication<Track>? publication;
  final List<TranscriptionSegment> segments;
  const TranscriptionEvent({
    required this.participant,
    required this.publication,
    required this.segments,
  });
}

class ParticipantNameUpdatedEvent with RoomEvent, ParticipantEvent {
  final Participant participant;
  final String name;
  const ParticipantNameUpdatedEvent({
    required this.participant,
    required this.name,
  });

  @override
  String toString() => '${runtimeType}'
      '(participant: ${participant}, name: ${name})';
}

class AudioPlaybackStatusChanged with RoomEvent {
  final bool isPlaying;
  const AudioPlaybackStatusChanged({
    required this.isPlaying,
  });

  @override
  String toString() => '${runtimeType}'
      'Audio Playback Status Changed, isPlaying: ${isPlaying})';
}

class AudioSenderStatsEvent with TrackEvent {
  final AudioSenderStats stats;
  final num currentBitrate;
  const AudioSenderStatsEvent({
    required this.stats,
    required this.currentBitrate,
  });

  @override
  String toString() => '${runtimeType}'
      'stats: ${stats})';
}

class VideoSenderStatsEvent with TrackEvent {
  final Map<String, VideoSenderStats> stats;
  final Map<String, num> bitrateForLayers;
  final num currentBitrate;
  const VideoSenderStatsEvent({
    required this.stats,
    required this.currentBitrate,
    required this.bitrateForLayers,
  });

  @override
  String toString() => '${runtimeType}'
      'stats: ${stats})';
}

class AudioReceiverStatsEvent with TrackEvent {
  final AudioReceiverStats stats;
  final num currentBitrate;
  const AudioReceiverStatsEvent({
    required this.stats,
    required this.currentBitrate,
  });

  @override
  String toString() => '${runtimeType}'
      'stats: ${stats})';
}

class VideoReceiverStatsEvent with TrackEvent {
  final VideoReceiverStats stats;
  final num currentBitrate;
  const VideoReceiverStatsEvent({
    required this.stats,
    required this.currentBitrate,
  });

  @override
  String toString() => '${runtimeType}'
      'stats: ${stats})';
}

class AudioVisualizerEvent with TrackEvent {
  final Track track;
  final List<Object?> event;
  const AudioVisualizerEvent({
    required this.track,
    required this.event,
  });

  @override
  String toString() => '${runtimeType}'
      'track: ${track})';
}

class TrackProcessorUpdateEvent with TrackEvent {
  final Track track;
  final TrackProcessor? processor;
  const TrackProcessorUpdateEvent({
    required this.track,
    this.processor,
  });

  @override
  String toString() => '${runtimeType}'
      'track: ${track})';
}
