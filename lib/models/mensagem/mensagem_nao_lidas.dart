class UnreadMessageCount {
  final int reclamacaoId;
  final int quantidade;

  UnreadMessageCount({
    required this.reclamacaoId,
    required this.quantidade,
  });

  factory UnreadMessageCount.fromMap(String key, dynamic value) {
    return UnreadMessageCount(
      reclamacaoId: int.parse(key),
      quantidade: value ?? 0,
    );
  }
}
