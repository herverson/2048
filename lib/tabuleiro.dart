import 'dart:math' show Random;

class Tabuleiro
{
  final int linha;
  final int coluna;
  int pontos;

  Tabuleiro(this.linha, this.coluna);

  List<List<Quadro>> tabQuadros;

  void inicTabuleiro()
  {
    tabQuadros = List.generate(
      4,
      (l) => List.generate(
        4, 
        (c) => Quadro(
          linha: l,
          coluna: c,
          valor: 0,
          isNovo: false,
          podeMesclar: false,
        ),
      ),
    );
    
    pontos = 0;
  }

  Quadro getQuadro(int linha, int coluna)
  {
    return tabQuadros[linha][coluna];
  }

  void randomVazioQuadro()
  {
    List<Quadro> vazio = List<Quadro>();

    tabQuadros.forEach((linhas)
    {
      vazio.addAll(linhas.where((quadro) => quadro.isVazio()));
    });

    if (vazio.isEmpty)
    {
      return;
    }

    Random rn = Random();
    for (int i = 0; i < 4; i++)
    {
      int indice = rn.nextInt(vazio.length);
      vazio[indice].valor = rn.nextInt(9) == 0 ? 4 : 2;
      vazio[indice].isNovo = true;
      vazio.removeAt(indice);
    }
  }

}

class Quadro 
{
  int linha, coluna;
  int valor;
  bool podeMesclar;
  bool isNovo;

  Quadro(
    {
      this.linha,
      this.coluna, 
      this.valor = 0, 
      this.podeMesclar, 
      this.isNovo
    }
  );

  bool isVazio() => valor == 0;

  @override
  int get hashCode
  {
    return valor.hashCode;
  }

  @override 
  operator == (outro)
  {
    return outro is Quadro && valor == outro.valor;
  }
}