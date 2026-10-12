/// Module: messaging / chat / data/models/message/poll_message_model.dart
//Youssef Ashraf


import '../../../../m2_connections/data/models/member_model.dart';

class PollMessageModel {
  List<String> options;
  bool isMultible;
  String question;
  late List<bool> pollValues;
  late List<int> votes;
  Map<String, List<Member>> voters;

  int? selectedOptionIndex;
  PollMessageModel({
    required this.options,
    required this.question,
    required this.pollValues,
    required this.votes,
    this.isMultible = false,
    this.voters = const {},
  }) {
    voters = {
      for (var option in options) option: [],
    };
  }

  PollMessageModel copyWith({
    List<int>? checkBoxes,
    List<String>? options,
    String? question,
    List<bool>? pollValues,
    List<int>? votes,
    bool? isMultiple,
    Map<String, List<Member>>? voters,
  }) {
    return PollMessageModel(
      options: options ?? this.options,
      question: question ?? this.question,
      pollValues: pollValues ?? this.pollValues,
      votes: votes ?? this.votes,
      isMultible: isMultiple ?? isMultible,
      voters: voters ?? this.voters,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pollValues': pollValues,
      'options': options,
    };
  }

  factory PollMessageModel.fromMap(Map<String, dynamic> map) {
    return PollMessageModel(
        pollValues: List<bool>.from(
          (map['pollValues'] as List<bool>),
        ),
        votes: List<int>.from(
          (map['votes'] as List<int>),
        ),
        question: map['question'],
        options: List<String>.from(
          (map['options'] as List<String>),
        ));
  }

  double calcPercentages({required int currentVoteNumbers}) {
    final totalVotes = getTotalVotes();

    if (totalVotes == 0) {
      return currentVoteNumbers == 0 ? 0 : 1;
    }
    return currentVoteNumbers / totalVotes;
  }

  int getTotalVotes() {
    int totalVotes = 0;

    for (int vote in votes) {
      totalVotes += vote;
    }
    return totalVotes;
  }

  int uniqueMembersVotes() {
//remove duplicate if multi selection available
    final allMembers = [];
    voters.forEach(
      (key, value) {
        allMembers.addAll(value);
      },
    );
    final ids = <dynamic>{};
    allMembers.retainWhere((x) {
      return ids.add(x.id);
    });

    return allMembers.length;
  }
}