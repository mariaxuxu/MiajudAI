class OnboardingData {
  final String nomeUsuario;
  final String telefoneUsuario;
  final String idade; // formato: YYYY-MM-DD
  final String endereco;
  final String cpfRg;
  final String? contatoEmergNome;
  final String? contatoEmergTel;
  final String? preferenciadieta;

  OnboardingData({
    required this.nomeUsuario,
    required this.telefoneUsuario,
    required this.idade,
    required this.endereco,
    required this.cpfRg,
    this.contatoEmergNome,
    this.contatoEmergTel,
    this.preferenciadieta,
  });

  Map<String, dynamic> toJson() => {
    'nome_usuario': nomeUsuario,
    'telefone_usuario': telefoneUsuario,
    'idade': idade,
    'endereco': endereco,
    'cpf_rg': cpfRg,
    'contato_emerg_nome': contatoEmergNome,
    'contato_emerg_tel': contatoEmergTel,
    'preferencia_dieta': preferenciadieta,
  };
}
