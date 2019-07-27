import 'dart:math' show Random;

class Tabuleiro 
{
  final int linha;
  final int coluna;
  int pontos;

  Tabuleiro(this.linha, this.coluna);

  List<List<Quadro>> _tabQuadros;

  void initTabuleiro() 
  {
    _tabQuadros = List.generate(
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

    print(_tabQuadros);

    pontos = 0;
    resetPodeMesclar();
    randomVazioQuadro();
    randomVazioQuadro();
  }

  void moveEsquerda() 
  {
    if (!podeMoveEsquerda()) 
    {
      return;
    }

    for (int l = 0; l < linha; ++l) 
    {
      for (int c = 0; c < coluna; ++c) 
      {
        mesclarEsquerda(l, c);
      }
    }
    randomVazioQuadro();
    resetPodeMesclar();
  }

  void moveDireita() 
  {
    if (!podeMoveDireita()) 
    {
      return;
    }

    for (int l = 0; l < linha; ++l) 
    {
      for (int c = coluna - 2; c >= 0; --c) 
      {
        mesclarDireita(l, c);
      }
    }
    randomVazioQuadro();
    resetPodeMesclar();
  }

  void moveUp() 
  {
    if (!podeMoveUp()) 
    {
      return;
    }

    for (int l = 0; l < linha; ++l) 
    {
      for (int c = 0; c < coluna; ++c) 
      {
        mesclarUp(l, c);
      }
    }
    randomVazioQuadro();
    resetPodeMesclar();
  }

  void moveDown() 
  {
    if (!podeMoveDown()) 
    {
      return;
    }

    for (int l = linha - 2; l >= 0; --l) 
    {
      for (int c = 0; c < coluna; ++c) 
      {
        mesclarDown(l, c);
      }
    }
    randomVazioQuadro();
    resetPodeMesclar();
  }

  bool podeMoveEsquerda() 
  {
    for (int l = 0; l < linha; ++l) 
    {
      for (int c = 1; c < coluna; ++c) 
      {
        if (podeMesclar(_tabQuadros[l][c], _tabQuadros[l][c - 1])) 
        {
          return true;
        }
      }
    }
    return false;
  }

  bool podeMoveDireita() 
  {
    for (int l = 0; l < linha; ++l) 
    {
      for (int c = coluna - 2; c >= 0; --c) 
      {
        if (podeMesclar(_tabQuadros[l][c], _tabQuadros[l][c + 1])) 
        {
          return true;
        }
      }
    }
    return false;
  }

  bool podeMoveUp() 
  {
    for (int l = 1; l < linha; ++l) 
    {
      for (int c = 0; c < coluna; ++c) 
      {
        if (podeMesclar(_tabQuadros[l][c], _tabQuadros[l - 1][c])) 
        {
          return true;
        }
      }
    }
    return false;
  }

  bool podeMoveDown() 
  {
    for (int l = linha - 2; l >= 0; --l) 
    {
      for (int c = 0; c < coluna; ++c) 
      {
        if (podeMesclar(_tabQuadros[l][c], _tabQuadros[l + 1][c])) 
        {
          return true;
        }
      }
    }
    return false;
  }

  void mesclarEsquerda(int linha, int col) 
  {
    while (col > 0) 
    {
      mesclar(_tabQuadros[linha][col], _tabQuadros[linha][col - 1]);
      col--;
    }
  }

  void mesclarDireita(int linha, int col) 
  {
    while (col < coluna - 1) 
    {
      mesclar(_tabQuadros[linha][col], _tabQuadros[linha][col + 1]);
      col++;
    }
  }

  void mesclarUp(int l, int col) 
  {
    while (l > 0) 
    {
      mesclar(_tabQuadros[l][col], _tabQuadros[l - 1][col]);
      l--;
    }
  }

  void mesclarDown(int l, int col) 
  {
    while (l < linha - 1) 
    {
      mesclar(_tabQuadros[l][col], _tabQuadros[l + 1][col]);
      l++;
    }
  }

  bool podeMesclar(Quadro a, Quadro b) 
  {
    return !a.podeMesclar &&
        ((b.isEmpty() && !a.isEmpty()) || (!a.isEmpty() && a == b));
  }

  void mesclar(Quadro a, Quadro b) 
  {
    if (!podeMesclar(a, b)) 
    {
      if (!a.isEmpty() && !b.podeMesclar) 
      {
        b.podeMesclar = true;
      }
      return;
    }

    if (b.isEmpty()) 
    {
      b.valor = a.valor;
      a.valor = 0;
    } 
    else if (a == b) 
    {
      b.valor = b.valor * 2;
      a.valor = 0;
      pontos += b.valor;
      b.podeMesclar = true;
    }
    else 
    {
      b.podeMesclar = true;
    }
  }

  bool gameOver() 
  {
    return !podeMoveEsquerda() && !podeMoveDireita() && !podeMoveUp() && !podeMoveDown();
  }

  Quadro getQuadro(int linha, int coluna) 
  {
    return _tabQuadros[linha][coluna];
  }

  void randomVazioQuadro() 
  {
    List<Quadro> empty = List<Quadro>();

    _tabQuadros.forEach((rows) {
      empty.addAll(rows.where((tile) => tile.isEmpty()));
    });

    if (empty.isEmpty) 
    {
      return;
    }

    Random rng = Random();

    int index = rng.nextInt(empty.length);
    empty[index].valor = rng.nextInt(9) == 0 ? 4 : 2;
    empty[index].isNovo = true;
    empty.removeAt(index);
  }

  void resetPodeMesclar()
  {
    _tabQuadros.forEach((rows) {
      rows.forEach((tile) {
        tile.podeMesclar = false;
      });
    });
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
    this.isNovo,
  });

  bool isEmpty() 
  {
    return valor == 0;
  }

  @override
  int get hashCode 
  {
    return valor.hashCode;
  }

  @override
  operator ==(other) 
  {
    return other is Quadro && valor == other.valor;
  }
}