/// Module: settings / se7_app_info / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: terms_and_conditions.dart
/// Purpose: "Terms And Conditions" — the per-company document, fetched from
///          Firestore and rendered as markdown.
/// Author: Knowticed Plus team
/// Updated: 21/9/2026 — the page used to render a hard-coded markdown string
///          (the same text for every company). It now reads
///          Company_Data/terms_and_conditions/templates exactly the way
///          Privacy Statement and About This Platform read theirs
///          (`assignedCompanies` filter, `descriptionEn` / `descriptionAr`,
///          `lastUpdateDate`), with the same header, loading, empty and
///          error states. Built from about_this_app_screen.dart.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:knowticed_plus/core/constants/firebase_collections.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/network/api_constants.dart'
    hide FirebaseCollections;
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class TermsConditions extends StatefulWidget {
  const TermsConditions({super.key});

  @override
  State<TermsConditions> createState() => _TermsConditionsState();
}

class _TermsConditionsState extends State<TermsConditions> {
  static const String _icon =
      'assets/icons_assets/settings_assets/requests_edit_document.svg';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  String? _description;
  DateTime? _lastUpdateDate;

  /// Null while things are fine. Holds a key, not a sentence: the text is
  /// resolved at build time so it follows a locale switch.
  _TermsError? _error;

  /// The fetch reads `Localizations.localeOf(context)`, which is not available
  /// in initState — hence didChangeDependencies, guarded so an inherited-widget
  /// change does not refetch on every rebuild.
  bool _fetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_fetched) return;
    _fetched = true;
    _fetchTermsData();
  }

  /// `ApiConstants.baseUri` is "Demo/75440689" or just the id; the company is
  /// the last segment either way.
  String? _currentCompanyId() {
    final String baseUri = ApiConstants.baseUri;
    if (baseUri.isEmpty) return null;

    final String last = baseUri.split('/').last;
    return last.isNotEmpty ? last : null;
  }

  Future<void> _fetchTermsData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final String? companyId = _currentCompanyId();
      if (companyId == null) {
        setState(() {
          _isLoading = false;
          _error = _TermsError.noCompany;
        });
        return;
      }

      // Company_Data/<doc>/templates, filtered to this company — the same
      // shape as 'privacy_policy' and 'about_this_app'. The admin side's doc
      // id for Terms is not referenced anywhere in this app, so the usual
      // spellings are tried in order and the first with a match wins.
      QuerySnapshot<Map<String, dynamic>>? snapshot;
      for (final String docId in _kTermsDocIds) {
        final QuerySnapshot<Map<String, dynamic>> result = await _firestore
            .collection(FirebaseCollections.adminRoot)
            .doc(FirebaseCollections.companyData)
            .collection(docId)
            .where('assignedCompanies', arrayContains: companyId)
            .limit(1)
            .get();
        if (result.docs.isNotEmpty) {
          snapshot = result;
          break;
        }
      }
      if (snapshot == null) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _error = _TermsError.empty;
        });
        return;
      }

      if (!mounted) return;

      if (snapshot.docs.isEmpty) {
        setState(() {
          _isLoading = false;
          _error = _TermsError.empty;
        });
        return;
      }

      final Map<String, dynamic> data = snapshot.docs.first.data();
      final bool isArabic =
          Localizations.localeOf(context).languageCode == 'ar';

      setState(() {
        _description = _clean(
          isArabic
              ? data['descriptionAr'] as String?
              : data['descriptionEn'] as String?,
        );

        final Object? updated = data['lastUpdateDate'];
        _lastUpdateDate = updated is Timestamp ? updated.toDate() : null;

        _isLoading = false;
        // A document that exists but has no body for this language is the same
        // dead end as no document at all, so it reports the same way.
        if (_description == null || _description!.isEmpty) {
          _error = _TermsError.empty;
        }
      });
    } catch (_) {
      if (!mounted) return;
      // The raw Firestore message is not surfaced — it is not something a user
      // can act on, and Retry is the only useful response.
      setState(() {
        _isLoading = false;
        _error = _TermsError.failed;
      });
    }
  }

  /// Strips the wrapping quotes the console adds when a long description is
  /// pasted as a triple-quoted or quoted string. Carried over from the previous
  /// implementation — the stored documents really do contain them.
  String? _clean(String? raw) {
    if (raw == null) return null;

    String value = raw.trim();
    if (value.startsWith("'''") && value.endsWith("'''") && value.length > 6) {
      value = value.substring(3, value.length - 3);
    }
    if (value.startsWith('"') && value.endsWith('"') && value.length > 1) {
      value = value.substring(1, value.length - 1);
    }
    return value.trim();
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    if (!isTablet) {
      // Phones push this as its own route, so it owns a Scaffold — the same
      // split TermsConditions uses.
      //
      // FIXED 8/9/2026 — the content pane used to be `Expanded`, which threw
      // "RenderFlex children have non-zero flex but incoming height
      // constraints are unbounded" the moment the page opened on a phone:
      // SideFrameMasterServices wraps `child` in a SingleChildScrollView on
      // mobile, so this Column has no bounded height for a flex child to
      // divide. The markdown body is itself a scrollable and needs a real
      // height either way — it now takes one from the viewport.
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SideFrameMasterServices(
          titleText: S.of(context).settings,
          secondTitle: FormatHelper.capitalize(S.of(context).termsAndConditions),
          onFirstTap: () => Navigator.pop(context),
          onSecondTap: () => Navigator.pop(context),
          child: Column(
            children: <Widget>[
              _header(context),
              SizedBox(
                height: _phoneContentHeight(context),
                child: _contentPane(context),
              ),
            ],
          ),
        ),
      );
    }

    // Tablet / desktop: rendered inside settings_layout's Expanded, which does
    // hand down a bounded height — so `Expanded` is correct here.
    return Column(
      children: <Widget>[
        _header(context),
        Expanded(child: _contentPane(context)),
      ],
    );
  }

  /// Height handed to the scrollable document pane on phones.
  ///
  /// The frame above it (safe area + breadcrumb + the 20.sp gap the frame
  /// inserts) takes roughly a fifth of the viewport, and this page's own header
  /// card sits under that. What is left is what the markdown gets. It is a
  /// fraction rather than a measured value on purpose: the pane lives inside
  /// the frame's SingleChildScrollView, so being a little short just means the
  /// page scrolls, and being a little tall is impossible to hit.
  double _phoneContentHeight(BuildContext context) {
    final MediaQueryData mq = MediaQuery.of(context);
    final double usable =
        mq.size.height - mq.padding.top - mq.padding.bottom;
    return usable * 0.72;
  }

  /// Title card above the content.
  ///
  /// CHANGED 21/9/2026 — the same header as Privacy Statement: the app logo
  /// with "Last Update" in the top-right corner, then the icon + title row.
  Widget _header(BuildContext context) {
    final bool lightMode = Theme.of(context).brightness == Brightness.light;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.r),
          topRight: Radius.circular(8.r),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(15.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Same asset choice as privacy_Statement.dart's pane.
                SvgPicture.asset(
                  !lightMode
                      ? 'assets/icons_assets/main_icons_assets/light_app_icon.svg'
                      : 'assets/icons_assets/main_icons_assets/logo_app.svg',
                  width: 50.w,
                  height: 50.h,
                  fit: BoxFit.fill,
                ),
                const Spacer(),
                if (_lastUpdateDate != null) ...<Widget>[
                  Text('${S.of(context).lastUpdate}: ',
                      style: StyleText.fontSize12Weight500
                          .copyWith(color: AppColors.secondaryText)),
                  Text(_formattedLastUpdate(context),
                      style: StyleText.fontSize12Weight500
                          .copyWith(color: AppColors.text)),
                ],
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              children: <Widget>[
                CustomSvgImage(
                  assetPath: _icon,
                  width: 25,
                  height: 25,
                  fit: BoxFit.fill,
                ),
                SizedBox(width: 5.w),
                Expanded(
                  child: Text(
                    FormatHelper.capitalize(S.of(context).termsAndConditions),
                    style: StyleText.fontSize16Weight500
                        .copyWith(color: AppColors.secondaryText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _contentPane(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // Not `const`: AppColors.card is a theme-dependent getter, not a
        // compile-time constant.
        color: AppColors.card,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircleProgressMaster());
    }

    if (_error != null) {
      return _errorState(context, _error!);
    }

    return Markdown(
      padding: EdgeInsets.all(15.sp),
      data: _description!,
      onTapLink: (String text, String? url, String title) async {
        if (url == null) return;
        final Uri link = url.contains('@') && !url.startsWith('http')
            ? Uri(scheme: 'mailto', path: url)
            : Uri.parse(url);
        await launchUrl(link, mode: LaunchMode.externalApplication);
      },
      // Same typography as TermsConditions so the two documents read
      // identically.
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        p: StyleText.fontSize14Weight500.copyWith(
          color: AppColors.secondaryText,
          height: 1.6,
        ),
        h1: StyleText.fontSize16Weight600.copyWith(
          color: AppColors.text,
          height: 1.8,
        ),
        h2: StyleText.fontSize15Weight600.copyWith(
          color: AppColors.text,
          height: 1.8,
        ),
        h3: StyleText.fontSize14Weight600.copyWith(
          color: AppColors.text,
          height: 1.8,
        ),
        listBullet: StyleText.fontSize14Weight500.copyWith(
          color: AppColors.secondaryText,
          height: 1.6,
        ),
      ),
    );
  }

  /// The last-update date in the app locale — Arabic-Indic numerals in
  /// Arabic, as the rest of the app does. Shown in the header since 21/9/2026
  /// (it used to be appended to the markdown as an italic footer line).
  String _formattedLastUpdate(BuildContext context) {
    final String locale = Localizations.localeOf(context).languageCode;
    return DateFormat('dd MMMM yyyy', locale).format(_lastUpdateDate!);
  }

  Widget _errorState(BuildContext context, _TermsError error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              _messageFor(context, error),
              textAlign: TextAlign.center,
              style: StyleText.fontSize14Weight500
                  .copyWith(color: AppColors.secondaryText),
            ),
            // Retry is offered only where it can help. A company that has no
            // document assigned will not grow one by tapping again.
            if (error == _TermsError.failed) ...<Widget>[
              SizedBox(height: 16.h),
              customButton(
                title: S.of(context).retry,
                function: _fetchTermsData,
                width: 150.w,
                height: 36,
                radius: 4.r,
                color: AppColors.primary,
                textStyle: StyleText.fontSize14Weight500
                    .copyWith(color: AppColors.textButton),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _messageFor(BuildContext context, _TermsError error) {
    switch (error) {
      case _TermsError.failed:
        return S.of(context).anErrorOccurred;
      case _TermsError.noCompany:
      case _TermsError.empty:
        // Deliberately the same line for both: from the reader's side "your
        // company has no document" and "the document has no text in your
        // language" are the same outcome, and neither is actionable in-app.
        return S.of(context).noDataAvailable;
    }
  }
}

/// Why the page has nothing to render. Kept as an enum rather than a String so
/// the message can be resolved at build time and follow a locale switch.
enum _TermsError { noCompany, empty, failed }

const List<String> _kTermsDocIds = <String>[
  'terms_and_conditions',
  'terms_conditions',
  'terms',
];
