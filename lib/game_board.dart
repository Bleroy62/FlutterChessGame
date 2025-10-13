import 'package:echec/components/piece.dart';
import 'package:echec/components/square.dart';
import 'package:echec/helper/helper_methods.dart';
import 'package:echec/values/colors.dart';
import 'package:flutter/material.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  //chessboard
  late List<List<ChessPiece?>> board;

  //selected piece
  ChessPiece? selectedPiece;

  // row (-1 = none selected)
  int selectedRow = -1;

  // column (-1 = none selected)
  int selectedCol = -1;

  //list of valid moves of the current piece
  List<List<int>> validMoves = [];

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  //initialisation chessboard
  void _initializeBoard() {
    List<List<ChessPiece?>> newBoard = List.generate(
      8,
      (_) => List.generate(8, (index) => null),
    );

    //placement des pions
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = ChessPiece(
        type: ChessPieceType.pawn,
        isWhite: false,
        imagePath: 'lib/chessIcon/pawn.png',
      );
      newBoard[6][i] = ChessPiece(
        type: ChessPieceType.pawn,
        isWhite: true,
        imagePath: 'lib/chessIcon/pawn.png',
      );
    }

    //placement des tours
    newBoard[0][0] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: false,
      imagePath: 'lib/chessIcon/rook.png',
    );
    newBoard[0][7] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: false,
      imagePath: 'lib/chessIcon/rook.png',
    );
    newBoard[7][0] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: true,
      imagePath: 'lib/chessIcon/rook.png',
    );
    newBoard[7][7] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: true,
      imagePath: 'lib/chessIcon/rook.png',
    );

    //placement des cavaliers
    newBoard[0][1] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: false,
      imagePath: 'lib/chessIcon/knight.png',
    );
    newBoard[0][6] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: false,
      imagePath: 'lib/chessIcon/knight.png',
    );
    newBoard[7][1] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: true,
      imagePath: 'lib/chessIcon/knight.png',
    );
    newBoard[7][6] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: true,
      imagePath: 'lib/chessIcon/knight.png',
    );

    //placement des fous
    newBoard[0][2] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: false,
      imagePath: 'lib/chessIcon/bishop.png',
    );
    newBoard[0][5] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: false,
      imagePath: 'lib/chessIcon/bishop.png',
    );
    newBoard[7][2] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: true,
      imagePath: 'lib/chessIcon/bishop.png',
    );
    newBoard[7][5] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: true,
      imagePath: 'lib/chessIcon/bishop.png',
    );

    //placement des reines
    newBoard[0][3] = ChessPiece(
      type: ChessPieceType.queen,
      isWhite: false,
      imagePath: 'lib/chessIcon/queen.png',
    );
    newBoard[7][4] = ChessPiece(
      type: ChessPieceType.queen,
      isWhite: true,
      imagePath: 'lib/chessIcon/queen.png',
    );

    //placement des rois
    newBoard[0][4] = ChessPiece(
      type: ChessPieceType.king,
      isWhite: false,
      imagePath: 'lib/chessIcon/king.png',
    );
    newBoard[7][3] = ChessPiece(
      type: ChessPieceType.king,
      isWhite: true,
      imagePath: 'lib/chessIcon/king.png',
    );

    board = newBoard;
  }

  //user select a piece
  void pieceSelected(int row, int col) {
    setState(() {
      if (board[row][col] != null) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      }

      //if a piece is selected, calculate it's valid moves
      validMoves = calculateRawValidMoves(row, col, selectedPiece!);
    });
  }

  //calculate the raw valid moves of the selected piece
  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece piece) {
    List<List<int>> candidateMoves = [];

    //different direction base on color
    int direction = piece.isWhite ? -1 : 1;

    switch (piece.type) {
      case ChessPieceType.pawn:
        //forward by 1
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }
        //or 2 if on starting position
        if ((piece.isWhite && row == 6) || (!piece.isWhite && row == 1)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }
        //kill diagonaly
        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }
        break;
      case ChessPieceType.rook:
        var directions = [
          [-1, 0], //up
          [1, 0], //down
          [0, -1], //left
          [0, 1], //right
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] == null) {
              candidateMoves.add([newRow, newCol]);
            } else {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // kill
              }
              break; // blocked by any piece
            }
            i++;
          }
        }
        break;

      case ChessPieceType.knight:
        var knightMoves = [
          [-2, -1],
          [-2, 1],
          [-1, -2],
          [-1, 2],
          [1, -2],
          [1, 2],
          [2, -1],
          [2, 1],
        ];
        for (var move in knightMoves) {
          int newRow = row + move[0];
          int newCol = col + move[1];

          if (!isInBoard(newRow, newCol)) {
            continue;
          }

          // Si la case est vide, on peut y aller
          if (board[newRow][newCol] == null) {
            candidateMoves.add([newRow, newCol]);
          }
          // Si la case contient une pièce adverse, on peut la capturer
          else if (board[newRow][newCol]!.isWhite != piece.isWhite) {
            candidateMoves.add([newRow, newCol]);
          }
          // Si c'est une pièce de la même couleur, on ne peut pas y aller
        }
        break;

      case ChessPieceType.bishop:
        var directions = [
          [-1, -1], //up-left
          [-1, 1], //up-right
          [1, -1], //down-left
          [1, 1], //down-right
        ];
        for (var direction in directions) {
          var i = 1; // Commencer à 1, pas 0
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] == null) {
              candidateMoves.add([newRow, newCol]);
            } else {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // kill
              }
              break; // blocked by any piece
            }
            i++;
          }
        }
        break;
      case ChessPieceType.queen:
        // Combine rook and bishop moves
        var directions = [
          [-1, 0], [1, 0], [0, -1], [0, 1], // rook directions
          [-1, -1], [-1, 1], [1, -1], [1, 1], // bishop directions
        ];
        for (var dir in directions) {
          for (int i = 1; i < 8; i++) {
            int newRow = row + i * dir[0];
            int newCol = col + i * dir[1];
            if (!isInBoard(newRow, newCol)) break;
            if (board[newRow][newCol] == null) {
              candidateMoves.add([newRow, newCol]);
            } else {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
          }
        }
        break;
      case ChessPieceType.king:
        var directions = [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1],
        ];
        for (var dir in directions) {
          int newRow = row + dir[0];
          int newCol = col + dir[1];
          if (!isInBoard(newRow, newCol)) continue;
          if (board[newRow][newCol] == null) {
            candidateMoves.add([newRow, newCol]);
          } else {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
          }
        }
        break;
      default:
    }
    return candidateMoves;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: GridView.builder(
        itemCount: 8 * 8,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
        ),
        itemBuilder: (context, index) {
          int row = index ~/ 8;
          int col = index % 8;
          bool isSelected = (row == selectedRow && col == selectedCol);

          // check if the current square is a valid move
          bool isValidMove = false;
          for (var position in validMoves) {
            if (position[0] == row && position[1] == col) {
              isValidMove = true;
              break;
            }
          }

          return Square(
            isWhite: isWhite(index),
            piece: board[row][col],
            isSelected: isSelected,
            isValidMove: isValidMove,
            onTap: () => pieceSelected(row, col),
          );
        },
      ),
    );
  }
}
