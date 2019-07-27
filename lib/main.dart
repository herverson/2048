import 'package:flutter/material.dart';
import 'model/tabuleiro.dart';
import 'utils.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '2048 Herver',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: Scaffold(
        
        body: BoardWidget(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final _BoardWidgetState state;

  const MyHomePage({this.state});

  @override
  Widget build(BuildContext context) {
    
    Size boardSize = state.boardSize();
    double width = (boardSize.width - (state.coluna + 1) * state.tilePadding) /
        state.coluna;

    List<TileBox> backgroundBox = List<TileBox>();
    for (int r = 0; r < state.linha; ++r) {
      for (int c = 0; c < state.coluna; ++c) {
        TileBox tile = TileBox(
          left: c * width * state.tilePadding * (c + 1),
          top: r * width * state.tilePadding * (r + 1),
          size: width,
        );
        backgroundBox.add(tile);
      }
    }

    return Positioned(
      left: 0.0,
      top: 0.0,
      child: Container(
        width: state.boardSize().width,
        height: state.boardSize().width,
        decoration: BoxDecoration(
            color: Colors.pink, borderRadius: BorderRadius.circular(6.0)),
        child: Stack(
          children: backgroundBox,
        ),
      ),
    );
  }
}

class BoardWidget extends StatefulWidget {
  @override
  _BoardWidgetState createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget> {
  Tabuleiro _board;
  int linha;
  int coluna;
  bool _isMoving;
  bool gameOver;
  double tilePadding = 5.0;
  MediaQueryData _queryData;

  @override
  void initState() {
    super.initState();

    linha = 4;
    coluna = 4;
    _isMoving = false;
    gameOver = false;

    _board = Tabuleiro(linha, coluna);
    newGame();
  }

  void newGame() {
    setState(() {
      _board.initTabuleiro();
      gameOver = false;
    });
  }

  void gameover() {
    setState(() {
      if (_board.gameOver()) {
        gameOver = true;
      }
    });
  }

  Size boardSize() {
    Size size = _queryData.size;
    return Size(size.width, size.width);
  }

  @override
  Widget build(BuildContext context) {
    _queryData = MediaQuery.of(context);
    List<TileWidget> _tileWidgets = List<TileWidget>();
    for (int r = 0; r < linha; ++r) {
      for (int c = 0; c < coluna; ++c) {
        _tileWidgets.add(TileWidget(tile: _board.getQuadro(r, c), state: this));
      }
    }
    List<Widget> children = List<Widget>();

    children.add(MyHomePage(state: this));
    children.addAll(_tileWidgets);

    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(26.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                color: Colors.orange[100],
                width: 100.0,
                height: 60.0,
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[Text("Score: "), Text("${_board.pontos}")],
                )),
              ),
              FlatButton(
                child: Container(
                  width: 100.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      color: Colors.orange[100]),
                  child: Center(
                    child: Text("Novo Jogo!"),
                  ),
                ),
                onPressed: () {
                  newGame();
                },
              )
            ],
          ),
        ),
        Container(
            height: 40.0,
            child: Opacity(
              opacity: gameOver ? 1.0 : 0.0,
              child: Center(
                child: Text('Game Over'),
              ),
            )),
        Container(
          width: _queryData.size.width,
          height: _queryData.size.width,
          child: GestureDetector(
            onVerticalDragUpdate: (detail) {
              if (detail.delta.distance == 0 || _isMoving) {
                return;
              }
              _isMoving = true;
              if (detail.delta.direction > 0) {
                setState(() {
                  _board.moveDown();
                  gameover();
                });
              } else {
                setState(() {
                  _board.moveUp();
                  gameover();
                });
              }
            },
            onVerticalDragEnd: (d) {
              _isMoving = false;
            },
            onVerticalDragCancel: () {
              _isMoving = false;
            },
            onHorizontalDragUpdate: (d) {
              if (d.delta.distance == 0 || _isMoving) {
                return;
              }
              _isMoving = true;
              if (d.delta.direction > 0) {
                setState(() {
                  _board.moveEsquerda();
                  gameover();
                });
              } else {
                setState(() {
                  _board.moveDireita();
                  gameover();
                });
              }
            },
            onHorizontalDragEnd: (d) {
              _isMoving = false;
            },
            onHorizontalDragCancel: () {
              _isMoving = false;
            },
            child: Stack(
              children: children,
            ),
          ),
        )
      ],
    );
  }
}

class TileWidget extends StatefulWidget {
  final Quadro tile;
  final _BoardWidgetState state;

  const TileWidget({Key key, this.tile, this.state}) : super(key: key);
  @override
  _TileWidgetState createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(
        milliseconds: 200,
      ),
      vsync: this,
    );

    animation = Tween(begin: 0.0, end: 1.0).animate(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
    widget.tile.isNovo = false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tile.isNovo && !widget.tile.isEmpty()) {
      controller.reset();
      controller.forward();
      widget.tile.isNovo = false;
    } else {
      controller.animateTo(1.0);
    }

    return AnimatedTileWidget(
      tile: widget.tile,
      state: widget.state,
      animation: animation,
    );
  }
}

class AnimatedTileWidget extends AnimatedWidget {
  final Quadro tile;
  final _BoardWidgetState state;

  AnimatedTileWidget({
    Key key,
    this.tile,
    this.state,
    Animation<double> animation,
  }) : super(
          key: key,
          listenable: animation,
        );

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    double animationValue = animation.value;
    Size boardSize = state.boardSize();
    double width = (boardSize.width - (state.coluna + 1) * state.tilePadding) /
        state.coluna;

    if (tile.valor == 0) {
      return Container();
    } else {
      return TileBox(
        left: (tile.coluna * width + state.tilePadding * (tile.coluna + 1)) +
            width / 2 * (1 - animationValue),
        top: tile.linha * width +
            state.tilePadding * (tile.linha + 1) +
            width / 2 * (1 - animationValue),
        size: width * animationValue,
        color: quadroCores.containsKey(tile.valor)
            ? quadroCores[tile.valor]
            : Colors.orange[50],
        text: Text('${tile.valor}'),
      );
    }
  }
}

class TileBox extends StatelessWidget {
  final double left;
  final double top;
  final double size;
  final Color color;
  final Text text;

  const TileBox({
    Key key,
    this.left,
    this.top,
    this.size,
    this.color,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
        ),
        child: Center(
          child: text,
        ),
      ),
    );
  }
}