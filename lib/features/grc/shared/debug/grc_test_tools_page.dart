/// Module: GRC / shared / debug
///
/// ************************* FILE INFO *************************** ///
/// File Name: grc_test_tools_page.dart
/// Purpose: The screen behind the "GRC Test Tools" button on the GRC home
///          page. One target email, four actions (see [GrcTestTools]) and a
///          live report of what happened.
/// Author: Knowticed Plus team
/// Created At: 17/9/2026
///
/// HOW TO TEST
/// 1. Sign in with the demo account and open GRC → the flask button.
/// 2. Check the target email (the account you open on the phone).
/// 3. "Send all notifications" → the phone gets one push + one inbox entry
///    per GRC notification row.
/// 4. "Create calendar test data" → open Calendar on the phone as the target;
///    every GRC calendar card shows today / in the next days.
/// 5. "Check calendar" → what the target's calendar SHOULD contain.
/// 6. "Remove test data" when finished.
///
/// ⚠️ QA ONLY — hidden when [kGrcTestToolsEnabled] is false.
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/grc/shared/debug/grc_test_tools.dart';

class GrcTestToolsPage extends StatefulWidget {
  const GrcTestToolsPage({super.key});

  /// Opens the page as a normal route.
  static Future<void> open(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const GrcTestToolsPage()),
      );

  @override
  State<GrcTestToolsPage> createState() => _GrcTestToolsPageState();
}

class _GrcTestToolsPageState extends State<GrcTestToolsPage> {
  final TextEditingController _email =
      TextEditingController(text: kGrcTestDefaultTargetEmail);
  final List<GrcTestResult> _results = <GrcTestResult>[];
  bool _busy = false;
  String _status = '';

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  bool get _emailValid {
    final String e = _email.text.trim();
    return e.contains('@') && e.contains('.');
  }

  Future<void> _run(
    String title,
    Future<List<GrcTestResult>> Function(String email) action,
  ) async {
    if (_busy) return;
    if (!_emailValid) {
      setState(() => _status = 'Enter a valid target email first.');
      return;
    }
    setState(() {
      _busy = true;
      _status = '$title…';
      _results
        ..clear()
        ..add(GrcTestResult('▶ $title', ok: true));
    });
    try {
      final List<GrcTestResult> results = await action(_email.text);
      if (!mounted) return;
      final int failed = results.where((GrcTestResult r) => !r.ok).length;
      setState(() {
        _results.addAll(results);
        _status = failed == 0
            ? '$title — all ${results.length} step(s) OK'
            : '$title — $failed of ${results.length} step(s) need attention';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _results.add(GrcTestResult(title, ok: false, detail: '$e'));
        _status = '$title failed';
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _confirm(String message) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('GRC Test Tools'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Widget _action({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) =>
      SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: _busy ? null : onTap,
          icon: Icon(icon),
          label: Text(label),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GRC Test Tools')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            const Text(
              'Sends every GRC notification and builds GRC calendar data for '
              'the account below. Sign in with that account on your phone to '
              'see the results. QA only — this writes to the live tenant.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _email,
              enabled: !_busy,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Target email (the phone account)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.alternate_email),
              ),
            ),
            const SizedBox(height: 16),
            _action(
              icon: Icons.notifications_active_outlined,
              label: 'Send all GRC notifications',
              onTap: () async {
                if (!await _confirm('Send every GRC notification '
                    '(in-app + push) to ${_email.text.trim()}?')) {
                  return;
                }
                await _run(
                  'Send all notifications',
                  (String email) => GrcTestTools.sendAllNotifications(
                    targetEmail: email,
                    onProgress: (int done, int total) {
                      if (mounted) {
                        setState(() => _status = 'Sending $done / $total…');
                      }
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _action(
              icon: Icons.event_available_outlined,
              label: 'Create calendar test data',
              onTap: () async {
                if (!await _confirm('Create a "$kGrcTestModulePrefix" GRC '
                    'module owned by ${_email.text.trim()} with policies, '
                    'controls and reassignment requests?')) {
                  return;
                }
                await _run(
                  'Create calendar test data',
                  (String email) =>
                      GrcTestTools.seedCalendarData(targetEmail: email),
                );
              },
            ),
            const SizedBox(height: 10),
            _action(
              icon: Icons.approval_outlined,
              label: 'Create approvals test data (me as manager)',
              onTap: () async {
                if (!await _confirm('Submit evidence on the newest '
                    '"$kGrcTestModulePrefix" module with YOU as Department '
                    'Manager (champion: ${_email.text.trim()})? You get '
                    'Pending, Approved and Rejected approvals.')) {
                  return;
                }
                await _run(
                  'Create approvals test data',
                  (String email) =>
                      GrcTestTools.seedApprovals(targetEmail: email),
                );
              },
            ),
            const SizedBox(height: 10),
            _action(
              icon: Icons.assignment_turned_in_outlined,
              label: 'Create My Audits test data (me as owner)',
              onTap: () async {
                if (!await _confirm('Fill My Audits of the newest '
                    '"$kGrcTestModulePrefix" module for YOUR account '
                    '(Pending, Outstanding, Scored, Rejected, Overdue)?')) {
                  return;
                }
                await _run(
                  'Create My Audits test data',
                  (_) => GrcTestTools.seedMyAudits(),
                );
              },
            ),
            const SizedBox(height: 10),
            _action(
              icon: Icons.fact_check_outlined,
              label: 'Check calendar for this account',
              onTap: () => _run(
                'Check calendar',
                (String email) => GrcTestTools.checkCalendar(targetEmail: email),
              ),
            ),
            const SizedBox(height: 10),
            _action(
              icon: Icons.delete_outline,
              label: 'Remove all test data',
              color: Colors.red.shade700,
              onTap: () async {
                if (!await _confirm('Move every "$kGrcTestModulePrefix" '
                    'module to Removed?')) {
                  return;
                }
                await _run(
                  'Remove test data',
                  (_) => GrcTestTools.removeTestData(),
                );
              },
            ),
            const SizedBox(height: 16),
            if (_busy) const LinearProgressIndicator(),
            if (_status.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  _status,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            for (final GrcTestResult r in _results)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  r.ok ? Icons.check_circle : Icons.error_outline,
                  color: r.ok ? Colors.green : Colors.orange,
                  size: 20,
                ),
                title: Text(r.label),
                subtitle: r.detail.isEmpty ? null : Text(r.detail),
              ),
          ],
        ),
      ),
    );
  }
}
