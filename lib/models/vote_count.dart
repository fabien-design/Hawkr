class VoteCount {
  final int upvotes;
  final int downvotes;

  VoteCount({
    required this.upvotes,
    required this.downvotes,
  });

  int get total => upvotes + downvotes;
  
  double get ratio {
    if (total == 0) return 0;
    return upvotes / total;
  }

  factory VoteCount.fromJson(Map<String, dynamic> json) {
    return VoteCount(
      upvotes: json['upvotes'] ?? 0,
      downvotes: json['downvotes'] ?? 0,
    );
  }
}
