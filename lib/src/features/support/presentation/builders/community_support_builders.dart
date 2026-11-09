import 'package:flutter/widgets.dart';
import 'package:rendezvous_community/src/features/guest_support/presentation/builders/community_guest_support_details.dart';
import 'package:rendezvous_community/src/features/support/presentation/builders/community_support_details.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_list_state_details.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_part_builder.dart';

class CommunitySupportBuilders {
  const CommunitySupportBuilders({
    this.loading,
    this.empty,
    this.error,
    this.header,
    this.banner,
    this.ticketTile,
    this.sensitiveWarning,
    this.closedBar,
    this.ratingDialog,
    this.fakeCsWarning,
    this.systemNotice,
    this.officialSender,
    this.quickReplies,
    this.helpLink,
    this.topicPicker,
    this.topicTile,
    this.pageHeader,
    this.incidentBanner,
    this.intakeForm,
    this.intakeField,
    this.surveyReasons,
    this.replySuggestions,
    this.guestForm,
    this.guestSecurityNote,
    this.guestHeader,
  });

  final CommunityPartBuilder<CommunityListLoadingDetails>? loading;
  final CommunityPartBuilder<CommunityListEmptyDetails>? empty;
  final CommunityPartBuilder<CommunityListErrorDetails>? error;
  final CommunityPartBuilder<CommunitySupportHeaderDetails>? header;
  final CommunityPartBuilder<CommunitySupportBannerDetails>? banner;
  final CommunityPartBuilder<CommunitySupportTicketDetails>? ticketTile;
  final CommunityPartBuilder<CommunitySensitiveWarningDetails>? sensitiveWarning;
  final CommunityPartBuilder<CommunitySupportClosedDetails>? closedBar;
  final CommunityPartBuilder<CommunitySupportRatingDetails>? ratingDialog;
  final CommunityPartBuilder<CommunityFakeCsDetails>? fakeCsWarning;
  final CommunityPartBuilder<CommunitySupportNoticeDetails>? systemNotice;
  final CommunityPartBuilder<CommunityOfficialSenderDetails>? officialSender;
  final CommunityPartBuilder<CommunityQuickRepliesDetails>? quickReplies;
  final CommunityPartBuilder<CommunityHelpLinkDetails>? helpLink;
  final CommunityPartBuilder<CommunitySupportTopicPickerDetails>? topicPicker;
  final CommunityPartBuilder<CommunitySupportTopicDetails>? topicTile;
  final CommunityPartBuilder<CommunitySupportPageHeaderDetails>? pageHeader;
  final CommunityPartBuilder<CommunitySupportIncidentDetails>? incidentBanner;
  final CommunityPartBuilder<CommunitySupportIntakeDetails>? intakeForm;
  final CommunityPartBuilder<CommunitySupportIntakeFieldDetails>? intakeField;
  final CommunityPartBuilder<CommunitySupportSurveyReasonsDetails>? surveyReasons;
  final CommunityPartBuilder<CommunitySupportReplySuggestionsDetails>? replySuggestions;
  final CommunityPartBuilder<CommunityGuestFormDetails>? guestForm;
  final CommunityPartBuilder<CommunityGuestSecurityNoteDetails>? guestSecurityNote;
  final CommunityPartBuilder<CommunityGuestHeaderDetails>? guestHeader;

  static CommunitySupportBuilders of(BuildContext context, {bool listen = true}) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<CommunitySupportBuildersScope>()
        : context.getInheritedWidgetOfExactType<CommunitySupportBuildersScope>();
    return scope?.builders ?? const CommunitySupportBuilders();
  }

  CommunitySupportBuilders merge(CommunitySupportBuilders? other) {
    if (other == null) return this;
    return CommunitySupportBuilders(
      loading: other.loading ?? loading,
      empty: other.empty ?? empty,
      error: other.error ?? error,
      header: other.header ?? header,
      banner: other.banner ?? banner,
      ticketTile: other.ticketTile ?? ticketTile,
      sensitiveWarning: other.sensitiveWarning ?? sensitiveWarning,
      closedBar: other.closedBar ?? closedBar,
      ratingDialog: other.ratingDialog ?? ratingDialog,
      fakeCsWarning: other.fakeCsWarning ?? fakeCsWarning,
      systemNotice: other.systemNotice ?? systemNotice,
      officialSender: other.officialSender ?? officialSender,
      quickReplies: other.quickReplies ?? quickReplies,
      helpLink: other.helpLink ?? helpLink,
      topicPicker: other.topicPicker ?? topicPicker,
      topicTile: other.topicTile ?? topicTile,
      pageHeader: other.pageHeader ?? pageHeader,
      incidentBanner: other.incidentBanner ?? incidentBanner,
      intakeForm: other.intakeForm ?? intakeForm,
      intakeField: other.intakeField ?? intakeField,
      surveyReasons: other.surveyReasons ?? surveyReasons,
      replySuggestions: other.replySuggestions ?? replySuggestions,
      guestForm: other.guestForm ?? guestForm,
      guestSecurityNote: other.guestSecurityNote ?? guestSecurityNote,
      guestHeader: other.guestHeader ?? guestHeader,
    );
  }
}

class CommunitySupportBuildersScope extends InheritedWidget {
  const CommunitySupportBuildersScope({super.key, required this.builders, required super.child});

  final CommunitySupportBuilders builders;

  @override
  bool updateShouldNotify(CommunitySupportBuildersScope oldWidget) => !identical(builders, oldWidget.builders);
}

Widget buildSupportPart<T>(
  CommunityPartBuilder<T>? Function(CommunitySupportBuilders builders) slot,
  BuildContext context,
  T details,
  Widget fallback,
) => buildCommunityPart(slot(CommunitySupportBuilders.of(context)), context, details, fallback);
