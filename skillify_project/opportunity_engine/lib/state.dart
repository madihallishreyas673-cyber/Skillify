import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data.dart';

Map<String, String> _strMap(dynamic v) => v is Map
    ? v.map((k, x) => MapEntry(k.toString(), x.toString()))
    : <String, String>{};
Map<String, int> _intMap(dynamic v) => v is Map
    ? v.map((k, x) => MapEntry(k.toString(), (x is num) ? x.toInt() : 0))
    : <String, int>{};
Set<String> _strSet(dynamic v) =>
    v is List ? v.map((e) => e.toString()).toSet() : <String>{};
String _s(dynamic v) => v == null ? '' : v.toString();

class Profile {
  String education, experience, goal, hours;
  Set<String> interests, skills;
  Profile({
    this.education = '',
    this.experience = '',
    this.goal = '',
    this.hours = '',
    Set<String>? interests,
    Set<String>? skills,
  })  : interests = interests ?? <String>{},
        skills = skills ?? <String>{};

  Map<String, dynamic> toJson() => {
        'education': education,
        'experience': experience,
        'goal': goal,
        'hours': hours,
        'interests': interests.toList(),
        'skills': skills.toList(),
      };

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
        education: _s(j['education']),
        experience: _s(j['experience']),
        goal: _s(j['goal']),
        hours: _s(j['hours']),
        interests: _strSet(j['interests']),
        skills: _strSet(j['skills']),
      );
}

class Entry {
  String title, org, dates, details;
  Entry({this.title = '', this.org = '', this.dates = '', this.details = ''});
  Map<String, dynamic> toJson() =>
      {'title': title, 'org': org, 'dates': dates, 'details': details};
  factory Entry.fromJson(Map<String, dynamic> j) => Entry(
        title: _s(j['title']),
        org: _s(j['org']),
        dates: _s(j['dates']),
        details: _s(j['details']),
      );
}

class Resume {
  String name = '', email = '', phone = '', location = '', headline = '';
  String summary = '', links = '';
  List<String> skills = [];
  List<Entry> experience = [], education = [], projects = [];

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'location': location,
        'headline': headline,
        'summary': summary,
        'links': links,
        'skills': skills,
        'experience': experience.map((e) => e.toJson()).toList(),
        'education': education.map((e) => e.toJson()).toList(),
        'projects': projects.map((e) => e.toJson()).toList(),
      };

  static Resume fromJson(Map<String, dynamic> j) {
    List<Entry> ents(dynamic v) => v is List
        ? v.whereType<Map>().map((m) => Entry.fromJson(Map<String, dynamic>.from(m))).toList()
        : <Entry>[];
    final r = Resume();
    r.name = _s(j['name']);
    r.email = _s(j['email']);
    r.phone = _s(j['phone']);
    r.location = _s(j['location']);
    r.headline = _s(j['headline']);
    r.summary = _s(j['summary']);
    r.links = _s(j['links']);
    r.skills = j['skills'] is List ? (j['skills'] as List).map((e) => e.toString()).toList() : [];
    r.experience = ents(j['experience']);
    r.education = ents(j['education']);
    r.projects = ents(j['projects']);
    return r;
  }
}

class Msg {
  final bool user;
  final String text;
  Msg(this.user, this.text);
  Map<String, dynamic> toJson() => {'user': user, 'text': text};
  factory Msg.fromJson(Map<String, dynamic> j) => Msg(j['user'] == true, _s(j['text']));
}

class UserData {
  Profile profile = Profile();
  bool assessed = false;
  String? careerId;
  Map<String, String> doneAt = {};
  Map<String, int> quizBest = {};
  Set<String> bookmarks = {};
  Map<String, String> applications = {};
  Map<String, Map<String, dynamic>> jobCache = {};
  Set<String> projectsDone = {};
  Set<String> tasksDone = {};
  Resume resume = Resume();
  List<Msg> chat = [];
  String backendUrl = '';
  String backendKey = '';

  Map<String, dynamic> toJson() => {
        'profile': profile.toJson(),
        'assessed': assessed,
        'careerId': careerId,
        'doneAt': doneAt,
        'quizBest': quizBest,
        'bookmarks': bookmarks.toList(),
        'applications': applications,
        'jobCache': jobCache,
        'projectsDone': projectsDone.toList(),
        'tasksDone': tasksDone.toList(),
        'resume': resume.toJson(),
        'chat': chat.map((m) => m.toJson()).toList(),
        'backendUrl': backendUrl,
        'backendKey': backendKey,
      };

  static UserData fromJson(Map<String, dynamic> j) {
    final u = UserData();
    if (j['profile'] is Map) {
      u.profile = Profile.fromJson(Map<String, dynamic>.from(j['profile'] as Map));
    }
    u.assessed = j['assessed'] == true;
    u.careerId = j['careerId'] as String?;
    u.doneAt = _strMap(j['doneAt']);
    u.quizBest = _intMap(j['quizBest']);
    u.bookmarks = _strSet(j['bookmarks']);
    u.applications = _strMap(j['applications']);
    if (j['jobCache'] is Map) {
      (j['jobCache'] as Map).forEach((k, v) {
        if (v is Map) u.jobCache[k.toString()] = Map<String, dynamic>.from(v);
      });
    }
    u.projectsDone = _strSet(j['projectsDone']);
    u.tasksDone = _strSet(j['tasksDone']);
    if (j['resume'] is Map) {
      u.resume = Resume.fromJson(Map<String, dynamic>.from(j['resume'] as Map));
    }
    if (j['chat'] is List) {
      u.chat = (j['chat'] as List)
          .whereType<Map>()
          .map((m) => Msg.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    }
    u.backendUrl = _s(j['backendUrl']);
    u.backendKey = _s(j['backendKey']);
    return u;
  }
}

final AppState appState = AppState();

/// App state. In this first version accounts and progress are stored ON THIS
/// PHONE only (shared_preferences). Cloud sync and server accounts come later.
class AppState extends ChangeNotifier {
  SharedPreferences? _p;
  bool loaded = false;
  bool onboarded = false;
  String? email;
  String? name;
  UserData data = UserData();
  final Random _rnd = Random.secure();

  Future<void> init() async {
    try {
      _p = await SharedPreferences.getInstance();
      onboarded = _p!.getBool('onboarded') ?? false;
      final s = _p!.getString('session');
      if (s != null) {
        final acc = _accounts()[s];
        if (acc != null) {
          email = s;
          name = _s(acc['name']);
          _loadUser();
        }
      }
    } catch (_) {
      // Start fresh if storage is unreadable.
    }
    loaded = true;
    notifyListeners();
  }

  Map<String, Map<String, dynamic>> _accounts() {
    final raw = _p?.getString('accounts');
    if (raw == null) return {};
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return m.map((k, v) => MapEntry(k, Map<String, dynamic>.from(v as Map)));
    } catch (_) {
      return {};
    }
  }

  void _loadUser() {
    final raw = _p?.getString('u:$email');
    if (raw == null) {
      data = UserData();
      return;
    }
    try {
      data = UserData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      data = UserData();
    }
  }

  String _hash(String salt, String pw) =>
      sha256.convert(utf8.encode('$salt:$pw')).toString();

  Future<void> completeOnboarding() async {
    onboarded = true;
    await _p?.setBool('onboarded', true);
    notifyListeners();
  }

  Future<String?> register(String nm, String em, String pw) async {
    final key = em.trim().toLowerCase();
    final acc = _accounts();
    if (acc.containsKey(key)) {
      return 'An account with this email already exists on this phone. Please log in.';
    }
    final salt = base64Url.encode(List<int>.generate(16, (_) => _rnd.nextInt(256)));
    acc[key] = {'name': nm.trim(), 'salt': salt, 'hash': _hash(salt, pw)};
    await _p?.setString('accounts', jsonEncode(acc));
    await _p?.setString('session', key);
    email = key;
    name = nm.trim();
    data = UserData();
    data.resume.name = name ?? '';
    data.resume.email = key;
    await persist();
    notifyListeners();
    return null;
  }

  Future<String?> login(String em, String pw) async {
    final key = em.trim().toLowerCase();
    final acc = _accounts()[key];
    if (acc == null) return 'No account found for this email on this phone. Register first.';
    if (_hash(_s(acc['salt']), pw) != _s(acc['hash'])) return 'Wrong password. Please try again.';
    await _p?.setString('session', key);
    email = key;
    name = _s(acc['name']);
    _loadUser();
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    await _p?.remove('session');
    email = null;
    name = null;
    data = UserData();
    notifyListeners();
  }

  Future<void> persist() async {
    if (email == null) return;
    await _p?.setString('u:$email', jsonEncode(data.toJson()));
  }

  void _save() {
    persist();
    notifyListeners();
  }

  void finishAssessment(Profile p, String careerId) {
    data.profile = p;
    data.assessed = true;
    data.careerId = careerId;
    if (data.resume.skills.isEmpty) data.resume.skills = p.skills.toList();
    _save();
  }

  void toggleLesson(String id) {
    if (data.doneAt.containsKey(id)) {
      data.doneAt.remove(id);
    } else {
      data.doneAt[id] = DateTime.now().toIso8601String();
    }
    _save();
  }

  void recordQuiz(String careerId, int score) {
    final best = data.quizBest[careerId] ?? 0;
    if (score > best || !data.quizBest.containsKey(careerId)) {
      data.quizBest[careerId] = score;
    }
    _save();
  }

  void toggleBookmark(Job j) {
    if (data.bookmarks.contains(j.id)) {
      data.bookmarks.remove(j.id);
      if (!data.applications.containsKey(j.id)) data.jobCache.remove(j.id);
    } else {
      data.bookmarks.add(j.id);
      data.jobCache[j.id] = j.toJson();
    }
    _save();
  }

  void setApplication(Job j, String? status) {
    if (status == null) {
      data.applications.remove(j.id);
      if (!data.bookmarks.contains(j.id)) data.jobCache.remove(j.id);
    } else {
      data.applications[j.id] = status;
      data.jobCache[j.id] = j.toJson();
    }
    _save();
  }

  Job? jobById(String id) {
    final m = data.jobCache[id];
    if (m != null) return Job.fromJson(m);
    for (final j in demoJobs) {
      if (j.id == id) return j;
    }
    return null;
  }

  void toggleProject(String key) {
    if (!data.projectsDone.add(key)) data.projectsDone.remove(key);
    _save();
  }

  void toggleTask(String key) {
    if (!data.tasksDone.add(key)) data.tasksDone.remove(key);
    _save();
  }

  void addChat(Msg m) {
    data.chat.add(m);
    if (data.chat.length > 60) data.chat = data.chat.sublist(data.chat.length - 60);
    _save();
  }

  void clearChat() {
    data.chat = [];
    _save();
  }

  void setBackend(String url, String key) {
    data.backendUrl = url.trim();
    data.backendKey = key.trim();
    _save();
  }

  void resetProgress() {
    data.doneAt = {};
    data.quizBest = {};
    data.projectsDone = {};
    data.tasksDone = {};
    _save();
  }

  void touch() => notifyListeners();
}
