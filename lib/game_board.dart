import 'package:echec/components/piece.dart';
import 'package:echec/components/square.dart';
import 'package:echec/helper/helper_methods.dart';
import 'package:echec/values/colors.dart';
import 'package:flutter/material.dart';
import 'package:echec/components/dead_piece.dart';

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

  //list white dead piece taken by black
  List<ChessPiece> whitePiecesTaken = [];

  //list black dead piece taken by white
  List<ChessPiece> blackPiecesTaken = [];

  // bool to know whose turn it is
  bool isWhiteTurn = true;

  //initial position of kings (keep track of this to make it easier later to see if king is in check
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 5];
  bool checkStatus = false;

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
        imagePath: 'lib/chessIcon/pawnCapy.png',
      );
      newBoard[6][i] = ChessPiece(
        type: ChessPieceType.pawn,
        isWhite: true,
        imagePath: 'lib/chessIcon/pawnCapy.png',
      );
    }

    //placement des tours
    newBoard[0][0] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: false,
      imagePath: 'lib/chessIcon/rookCapy.png',
    );
    newBoard[0][7] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: false,
      imagePath: 'lib/chessIcon/rookCapy.png',
    );
    newBoard[7][0] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: true,
      imagePath: 'lib/chessIcon/rookCapy.png',
    );
    newBoard[7][7] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: true,
      imagePath: 'lib/chessIcon/rookCapy.png',
    );

    //placement des cavaliers
    newBoard[0][1] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: false,
      imagePath: 'lib/chessIcon/knightCapy.png',
    );
    newBoard[0][6] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: false,
      imagePath: 'lib/chessIcon/knightCapy.png',
    );
    newBoard[7][1] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: true,
      imagePath: 'lib/chessIcon/knightCapy.png',
    );
    newBoard[7][6] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: true,
      imagePath: 'lib/chessIcon/knightCapy.png',
    );

    //placement des fous
    newBoard[0][2] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: false,
      imagePath: 'lib/chessIcon/bishopCapy.png',
    );
    newBoard[0][5] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: false,
      imagePath: 'lib/chessIcon/bishopCapy.png',
    );
    newBoard[7][2] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: true,
      imagePath: 'lib/chessIcon/bishopCapy.png',
    );
    newBoard[7][5] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: true,
      imagePath: 'lib/chessIcon/bishopCapy.png',
    );

    //placement des reines
    newBoard[0][3] = ChessPiece(
      type: ChessPieceType.queen,
      isWhite: false,
      imagePath: 'lib/chessIcon/queenCapy.png',
    );
    newBoard[7][4] = ChessPiece(
      type: ChessPieceType.queen,
      isWhite: true,
      imagePath: 'lib/chessIcon/queenCapy.png',
    );

    //placement des rois
    newBoard[0][4] = ChessPiece(
      type: ChessPieceType.king,
      isWhite: false,
      imagePath: 'lib/chessIcon/kingCapy.png',
    );
    newBoard[7][3] = ChessPiece(
      type: ChessPieceType.king,
      isWhite: true,
      imagePath: 'lib/chessIcon/kingCapy.png',
    );

    board = newBoard;
  }

  //user select a piece
  void pieceSelected(int row, int col) {
    setState(() {
      if (selectedPiece == null && board[row][col] != null) {
        if (board[row][col]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }
      } else if (board[row][col] != null &&
          board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      } else if (selectedPiece != null &&
          validMoves.any((element) => element[0] == row && element[1] == col)) {
        movePiece(row, col);
      }

      //if a piece is selected, calculate it's valid moves
      validMoves = calculateRawValidMoves(row, col, selectedPiece!);
    });
  }

  //calculate the raw valid moves of the selected piece
  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];

    if (piece == null) {
      return [];
    }

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

  //move the piece
  void movePiece(int newRow, int newCol) {
    //if the newspot has an enemy piece
    if (board[newRow][newCol] != null) {
      // add the captue piece to the appropriate list
      var capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite) {
        whitePiecesTaken.add(capturedPiece);
      } else {
        blackPiecesTaken.add(capturedPiece);
      }
    }

    //move the piece and clear the old spot
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    // see if the kings are under attack
    if (isKingInCheck(!isWhiteTurn)) {
      checkStatus = true;
    } else {
      checkStatus = false;
    }

    //clear the selection
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    // change turn
    isWhiteTurn = !isWhiteTurn;
  }
    // is king in check
    bool isKingInCheck(bool isWhiteKing) {
      //get the position of the king
      List<int> kingPosition =
          isWhiteKing ? whiteKingPosition : blackKingPosition;

      // check if any enemy piece can attack the king
      for (int i = 0; i < 8; i++) {
        for (int j = 0; j < 8; i++) {
          // skip the squares and pieces of the same color as the king
          if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
            continue;
          }

          List<List<int>> pieceValidMoves = calculateRawValidMoves(
            i,
            j,
            board[i][j],
          );

          //check if the king's position is in this piece's valid moves
          if (pieceValidMoves.any(
            (move) => move[0] == kingPosition[0] && move[1] == kingPosition[1],
          )){
            return true;
          }
        }
      }
      return false; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // white pieces taken
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: whitePiecesTaken.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemBuilder:
                  (context, index) => DeadPiece(
                    imagePath: whitePiecesTaken[index].imagePath,
                    isWhite: true,
                  ),
            ),
          ),

          //chess board
          Expanded(
            flex: 3,
            child: GridView.builder(
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
          ),

          // black piece taken
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: blackPiecesTaken.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemBuilder:
                  (context, index) => DeadPiece(
                    imagePath: blackPiecesTaken[index].imagePath,
                    isWhite: false,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
