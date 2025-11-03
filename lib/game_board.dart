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
  List<int> blackKingPosition = [0, 4];
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

    // Placement des rois (position standard)
    newBoard[0][4] = ChessPiece(
      // Roi noir en e8
      type: ChessPieceType.king,
      isWhite: false,
      imagePath: 'lib/chessIcon/kingCapy.png',
    );
    newBoard[7][4] = ChessPiece(
      // Roi blanc en e1
      type: ChessPieceType.king,
      isWhite: true,
      imagePath: 'lib/chessIcon/kingCapy.png',
    );

    // Placement des reines (position standard)
    newBoard[0][3] = ChessPiece(
      // Reine noire en d8
      type: ChessPieceType.queen,
      isWhite: false,
      imagePath: 'lib/chessIcon/queenCapy.png',
    );
    newBoard[7][3] = ChessPiece(
      // Reine blanche en d1
      type: ChessPieceType.queen,
      isWhite: true,
      imagePath: 'lib/chessIcon/queenCapy.png',
    );

    board = newBoard;
  }

  //user select a piece
  void pieceSelected(int row, int col) {
    setState(() {
      // Si aucune pièce n'est sélectionnée et qu'on clique sur une pièce de la bonne couleur
      if (selectedPiece == null && board[row][col] != null) {
        if (board[row][col]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
          validMoves = calculateRealValidMoves(row, col, selectedPiece!, true);
        }
      }
      // Si une pièce est déjà sélectionnée
      else if (selectedPiece != null) {
        // Si on clique sur une autre pièce de la même couleur
        if (board[row][col] != null &&
            board[row][col]!.isWhite == selectedPiece!.isWhite) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
          validMoves = calculateRealValidMoves(row, col, selectedPiece!, true);
        }
        // Si on clique sur un mouvement valide
        else if (validMoves.any(
          (element) => element[0] == row && element[1] == col,
        )) {
          movePiece(row, col);
        }
        // Si on clique ailleurs, on désélectionne
        else {
          selectedPiece = null;
          selectedRow = -1;
          selectedCol = -1;
          validMoves = [];
        }
      }
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

  //calculate real valid moves considering checks
  List<List<int>> calculateRealValidMoves(
    int row,
    int col,
    ChessPiece? piece,
    bool checkSimulation,
  ) {
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece);

    // after generating all candidate moves, filter out any that would result in a check
    if (checkSimulation) {
      for (var move in candidateMoves) {
        int endRow = move[0];
        int endCol = move[1];
        if (simulationMoveIsSafe(piece!, row, col, endRow, endCol)) {
          realValidMoves.add(move);
        }
      }
    } else {
      realValidMoves = candidateMoves;
    }
    return realValidMoves;
  }

  //move the piece
  void movePiece(int newRow, int newCol) {
    if (board[newRow][newCol] != null) {
      var capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite) {
        whitePiecesTaken.add(capturedPiece);
      } else {
        blackPiecesTaken.add(capturedPiece);
      }
    }

    // Mettre à jour la position du roi si nécessaire
    if (selectedPiece!.type == ChessPieceType.king) {
      if (selectedPiece!.isWhite) {
        whiteKingPosition = [newRow, newCol];
      } else {
        blackKingPosition = [newRow, newCol];
      }
    }

    // Déplacer la pièce
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    // Vérifier si le roi du joueur qui VIENT de jouer est en échec
    // (c'est-à-dire si le coup qu'il vient de jouer met son propre roi en échec)
    if (isKingInCheck(selectedPiece!.isWhite)) {
      // Ce n'est pas un coup valide, annuler le mouvement
      board[selectedRow][selectedCol] = selectedPiece;
      board[newRow][newCol] = null;

      // Restaurer la position du roi si nécessaire
      if (selectedPiece!.type == ChessPieceType.king) {
        if (selectedPiece!.isWhite) {
          whiteKingPosition = [selectedRow, selectedCol];
        } else {
          blackKingPosition = [selectedRow, selectedCol];
        }
      }

      // Restaurer la pièce capturée si nécessaire
      if (board[newRow][newCol] == null &&
          (selectedRow != newRow || selectedCol != newCol)) {
        // La pièce capturée a été restaurée quand on a annulé le mouvement
      }

      setState(() {
        selectedPiece = null;
        selectedRow = -1;
        selectedCol = -1;
        validMoves = [];
      });
      return;
    }

    // Vérifier si le roi adverse est en échec après le mouvement
    if (isKingInCheck(!isWhiteTurn)) {
      checkStatus = true;
    } else {
      checkStatus = false;
    }

    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    // check if it's checkmate after the move
    if (isCheckMate(!isWhiteTurn)) {
      String winner = isWhiteTurn ? "Blancs" : "Noirs";
      _showCheckmateDialog(winner);
    }

    //change turn
    isWhiteTurn = !isWhiteTurn;
  }

  void _showCheckmateDialog(String winner) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.grey[900]!, Colors.grey[800]!],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Couronne animée
                  Image.asset(
                    'lib/images/tete_capybara.jpg',
                    width: 100,
                    height: 100,
                  ),

                  SizedBox(height: 15),

                  // Titre principal
                  Text(
                    "VICTOIRE!",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),

                  SizedBox(height: 10),

                  // Message du gagnant
                  Text(
                    "Les $winner gagnent par échec et mat",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 20),

                  // Boutons d'action
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).pop(); // Ferme la boîte de dialogue
                            resetGame(); // Réinitialise le jeu
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "NOUVELLE PARTIE",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildStat(String title, String value) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // is king in check
  bool isKingInCheck(bool isWhiteKing) {
    List<int> kingPosition =
        isWhiteKing ? whiteKingPosition : blackKingPosition;

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        // CORRECTION: j++ au lieu de i++
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves = calculateRealValidMoves(
          i,
          j,
          board[i][j],
          false,
        );

        if (pieceValidMoves.any(
          (move) => move[0] == kingPosition[0] && move[1] == kingPosition[1],
        )) {
          return true;
        }
      }
    }
    return false;
  }

  //simulate if a move is safe (doesn't put own king in check)
  bool simulationMoveIsSafe(
    ChessPiece piece,
    int startRow,
    int startCol,
    int endRow,
    int endCol,
  ) {
    ChessPiece? originalDestinationPiece = board[endRow][endCol];
    List<int> originalKingPosition = [];

    if (piece.type == ChessPieceType.king) {
      originalKingPosition =
          piece.isWhite ? whiteKingPosition : blackKingPosition;

      if (piece.isWhite) {
        whiteKingPosition = [endRow, endCol];
      } else {
        blackKingPosition = [endRow, endCol];
      }
    }

    // simulate the move
    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    // check if the king is in check after the move
    bool isInCheck = isKingInCheck(piece.isWhite);

    // restore the original board state
    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDestinationPiece;

    if (piece.type == ChessPieceType.king) {
      if (piece.isWhite) {
        whiteKingPosition = originalKingPosition;
      } else {
        blackKingPosition = originalKingPosition;
      }
    }

    return !isInCheck;
  }

  // is it check mate
  bool isCheckMate(bool isWhiteKing) {
    // if the king is not in check, it's not checkmate
    if (!isKingInCheck(isWhiteKing)) {
      return false;
    }
    // check if any move can get the king out of check
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] != null && board[i][j]!.isWhite == isWhiteKing) {
          List<List<int>> moves = calculateRealValidMoves(
            i,
            j,
            board[i][j],
            true,
          );
          for (var move in moves) {
            if (simulationMoveIsSafe(board[i][j]!, i, j, move[0], move[1])) {
              return false; // found a move that gets the king out of check
            }
          }
        }
      }
    }
    return true; // no moves found to get the king out of check
  }

 //reset the game
void resetGame() {
  // shut down any open dialogs
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  }
  
  // reset all variables
  setState(() {
    _initializeBoard();
    selectedPiece = null;
    selectedRow = -1;
    selectedCol = -1;
    validMoves = [];
    whitePiecesTaken.clear();
    blackPiecesTaken.clear();
    isWhiteTurn = true;
    checkStatus = false;
    whiteKingPosition = [7, 4];
    blackKingPosition = [0, 4];
  });
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
