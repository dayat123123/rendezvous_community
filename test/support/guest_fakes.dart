import 'package:rendezvous_community/rendezvous_community.dart';

const guestProblems = [
  GuestLoginProblem(code: 'password', label: 'Lupa password'),
  GuestLoginProblem(code: 'pin', label: 'Lupa PIN'),
  GuestLoginProblem(code: 'locked', label: 'Akun terkunci atau ditangguhkan'),
  GuestLoginProblem(code: 'other', label: 'Masalah login lainnya'),
];

final guestCreatedAt = DateTime.utc(2026, 11, 9, 2);

SupportTicket guestTicket({SupportStatus status = SupportStatus.open, int? queueAhead = 2, int? etaMinutes = 6}) =>
    SupportTicket(
      id: 'gt-1',
      ticketNumber: 'CS-20261109-0042',
      roomId: 'gr-1',
      topic: 'account',
      topicName: 'Akun & Login',
      status: status,
      queueAhead: status == SupportStatus.open ? queueAhead : null,
      etaMinutes: status == SupportStatus.open ? etaMinutes : null,
      agent: status == SupportStatus.claimed || status == SupportStatus.resolved
          ? const SupportAgent(displayName: 'Nadia', agentCode: 'CS07')
          : null,
      createdAt: guestCreatedAt,
    );

const guestAgent = UserSummary(id: 'a-1', username: 'cs_nadia', displayName: 'Nadia');

ChatMessage guestMessage(
  String id,
  String body, {
  SenderRole role = SenderRole.customer,
  int minute = 0,
  String? clientId,
  MessageKind kind = MessageKind.text,
  Map<String, Object?> payload = const {},
}) => ChatMessage(
  id: id,
  roomId: 'gr-1',
  senderId: switch (role) {
    SenderRole.agent || SenderRole.supervisor => guestAgent.id,
    SenderRole.customer => 'guest-1',
    SenderRole.system => null,
  },
  sender: role == SenderRole.agent ? guestAgent : null,
  body: body,
  clientId: clientId,
  createdAt: guestCreatedAt.add(Duration(minutes: minute)),
  senderRole: role,
  kind: kind,
  ticketId: 'gt-1',
  payload: payload,
);

class FakeGuestSupportRepository implements GuestSupportRepository {
  FakeGuestSupportRepository({
    this.configValue = const GuestSupportConfig(enabled: true, problems: guestProblems),
    SupportTicket? ticket,
    List<ChatMessage>? messages,
    DateTime? expiresAt,
  }) : ticket = ticket ?? guestTicket(),
       messages = messages ?? [],
       expiresAt = expiresAt ?? DateTime.now().add(const Duration(hours: 24));

  GuestSupportConfig configValue;
  SupportTicket ticket;
  List<ChatMessage> messages;
  DateTime expiresAt;
  Object? configError;
  Object? startError;
  Object? pollError;
  Object? sendError;
  Object? endError;
  int configCalls = 0;
  int pollCalls = 0;
  int endCalls = 0;
  final starts = <Map<String, Object?>>[];
  final sent = <String>[];
  final tokens = <String>[];
  int _sequence = 0;

  @override
  Future<GuestSupportConfig> config({String language = 'id'}) async {
    configCalls++;
    final error = configError;
    if (error != null) throw error;
    return configValue;
  }

  @override
  Future<GuestSupportSession> start({
    required String name,
    String? loginId,
    required String problem,
    required String description,
    String language = 'id',
  }) async {
    final error = startError;
    if (error != null) throw error;
    starts.add({
      'name': name,
      'loginId': normalizeGuestLoginId(loginId),
      'problem': problem,
      'description': description.trim(),
      'language': language,
    });
    messages = [...messages, guestMessage('m-first', description.trim())];
    return GuestSupportSession(
      token: GuestSupportToken(token: 'token-abcdefghijklmnopqrstuvwxyz', expiresAt: expiresAt),
      ticket: ticket,
    );
  }

  @override
  Future<GuestSupportSnapshot> poll(String token) async {
    pollCalls++;
    tokens.add(token);
    final error = pollError;
    if (error != null) throw error;
    return GuestSupportSnapshot(expiresAt: expiresAt, ticket: ticket, messages: List.of(messages));
  }

  @override
  Future<ChatMessage> send(String token, {required String body, required String clientId}) async {
    tokens.add(token);
    final error = sendError;
    if (error != null) throw error;
    sent.add(body);
    final message = guestMessage('m-sent-${_sequence++}', body.trim(), clientId: clientId, minute: 30 + _sequence);
    messages = [...messages, message];
    return message;
  }

  SupportTicket? endTicket;

  @override
  Future<SupportTicket?> end(String token) async {
    endCalls++;
    final error = endError;
    if (error != null) throw error;
    return endTicket;
  }

  void agentReply(String body, {int minute = 5}) {
    messages = [...messages, guestMessage('m-agent-${_sequence++}', body, role: SenderRole.agent, minute: minute)];
  }
}

class RecordingGuestSessionStore implements CommunityGuestSessionStore {
  RecordingGuestSessionStore({this.token, this.persistent = true});

  GuestSupportToken? token;
  int writes = 0;
  int clears = 0;

  @override
  final bool persistent;

  @override
  Future<GuestSupportToken?> read() async => token;

  @override
  Future<void> write(GuestSupportToken value) async {
    writes++;
    token = value;
  }

  @override
  Future<void> clear() async {
    clears++;
    token = null;
  }
}

CommunityException guestApiError(String code, CommunityErrorKind kind) =>
    CommunityException(kind, code: code, message: code);
