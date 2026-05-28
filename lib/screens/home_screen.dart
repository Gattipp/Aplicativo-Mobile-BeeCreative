import 'package:flutter/material.dart';
import 'drawing_canvas.dart'; // Importa a tela de desenho

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, //Ocupa a largura disponivel na tela
        height: double.infinity, //Ocupa a altura disponivel na tela
        decoration: const BoxDecoration( //Fundo degrade 
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFFFF3B0),
            ],
          ),
        ),
        child: SafeArea( //Garante que o conteudo não vai ficar escondido
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, //Centraliza na vertical
              children: [
                const Spacer(flex: 3), //Espaçamento

                //Logo
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: MediaQuery.of(context).size.width * 0.80,
                    fit: BoxFit.contain,
                  ),
                ),

                const Spacer(flex: 3), //Espaçamento proporcinal entre logo e botão

                //Botão Criar
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.pink,
                      side: const BorderSide(
                        color: Colors.amberAccent,
                        width: 2.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    label: const Text(
                      'CRIAR!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    onPressed: () { //Ao aperta o botão, será redirecionado para a tela de desenho 
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DrawingCanvas(),
                        ),
                      );
                    },
                  ),
                ),
                
                const Spacer(flex: 1), //Espaçamento
              ],
            ),
          ),
        ),
      ),
    );
  }
}
