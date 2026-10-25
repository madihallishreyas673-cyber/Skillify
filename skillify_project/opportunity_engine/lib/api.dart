import 'dart:convert';
import 'package:http/http.dart' as http;
import 'data.dart';
import 'state.dart';

const _skillKeywords = <String, List<String>>{
  'Excel/Sheets': ['excel', 'spreadsheet', 'google sheets'],
  'Figma/UI design': ['figma', 'ui design', 'ux design', 'ui/ux'],
  'Video editing': ['video edit', 'premiere', 'davinci', 'final cut'],
  'Prompt writing/AI tools': ['prompt', 'chatgpt', 'llm'],
  'No-code automation': ['zapier', 'make.com', 'n8n', 'automation'],
  'Photoshop/Photo editing': ['photoshop'],
  'Customer support': ['customer support', 'customer service', 'help desk'],
  'Data visualization': ['tableau', 'power bi', 'data visuali'],
  'Social media': ['social media'],
  'Email marketing': ['email marketing'],
  'Color grading': ['color grading', 'colour grading'],
  'Motion graphics': ['motion graphics', 'after effects'],
  'Problem solving': ['problem solving', 'problem-solving'],
};

String _stripHtml(String s) => s
    .replaceAll(RegExp(r'<[^>]*>'), ' ')
    .replaceAll('&nbsp;', ' ')
    .replaceAll('&amp;', '&')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

List<String> _inferTags(String text) {
  final t = text.toLowerCase();
  final out = <String>[];
  for (final s in allSkills) {
    final words = _skillKeywords[s] ?? [s.toLowerCase()];
    if (words.any((w) => t.contains(w))) out.add(s);
  }
  return out;
}

/// Live remote job listings from the public Remotive API (https://remotive.com).
/// Each listing links back to Remotive. If it fails, the app falls back to demo data.
Future<List<Job>> fetchLiveJobs(String term) async {
  final uri = Uri.https('remotive.com', '/api/remote-jobs', {'search': term, 'limit': '20'});
  final r = await http.get(uri).timeout(const Duration(seconds: 15));
  if (r.statusCode != 200) throw Exception('Job source returned ${r.statusCode}');
  final j = jsonDecode(r.body) as Map<String, dynamic>;
  final list = (j['jobs'] as List?) ?? [];
  final out = <Job>[];
  for (final e in list) {
    if (e is! Map) continue;
    final m = Map<String, dynamic>.from(e);
    final jt = (m['job_type'] ?? '').toString().toLowerCase();
    final type = jt.contains('intern')
        ? 'Internship'
        : (jt.contains('contract') || jt.contains('freelance'))
            ? 'Freelance'
            : 'Job';
    final plain = _stripHtml((m['description'] ?? '').toString());
    final title = (m['title'] ?? '').toString();
    final sal = (m['salary'] ?? '').toString().trim();
    final url = (m['url'] ?? '').toString();
    if (title.isEmpty || url.isEmpty) continue;
    out.add(Job(
      id: 'rem-${m['id']}',
      title: title,
      company: (m['company_name'] ?? '').toString(),
      type: type,
      location: (m['candidate_required_location'] ?? 'Remote').toString(),
      source: 'Remotive',
      description: plain.length > 700 ? '${plain.substring(0, 700)}...' : plain,
      salary: sal.isEmpty ? null : sal,
      url: url,
      demo: false,
      tags: _inferTags('$title $plain'),
      requirements: const [],
    ));
  }
  return out;
}

/// Optional: ask YOUR OWN backend (which keeps the AI key secret on the server).
Future<String> askBackend(String baseUrl, String key, List<Msg> history, Map<String, dynamic> context) async {
  var base = baseUrl.trim();
  if (base.endsWith('/')) base = base.substring(0, base.length - 1);
  final recent = history.length > 12 ? history.sublist(history.length - 12) : history;
  final r = await http
      .post(
        Uri.parse('$base/ai/chat'),
        headers: {
          'Content-Type': 'application/json',
          if (key.isNotEmpty) 'x-access-key': key,
        },
        body: jsonEncode({
          'messages': recent
              .map((m) => {'role': m.user ? 'user' : 'assistant', 'content': m.text})
              .toList(),
          'context': context,
        }),
      )
      .timeout(const Duration(seconds: 45));
  if (r.statusCode != 200) throw Exception('Server returned ${r.statusCode}');
  final j = jsonDecode(r.body) as Map<String, dynamic>;
  final reply = (j['reply'] ?? '').toString().trim();
  if (reply.isEmpty) throw Exception('Empty reply');
  return reply;
}
