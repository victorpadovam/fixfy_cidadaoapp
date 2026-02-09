// import 'package:flutter/material.dart';

// class BuscaDadosPerfilUser extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<SsoAnaBotEntity>>(
//       future: buscaDadosAPIPerfil(),
//       builder: (context, snapshot) {
//         switch (snapshot.connectionState) {
//           case ConnectionState.waiting:
//             return Center(
//               child: LogoLoading(),
//             );

//           case ConnectionState.none:
//             print("none");
//             break;
//           case ConnectionState.active:
//             print("active");
//             break;
//           case ConnectionState.done:
//             if (snapshot.hasError) {
//               return AlertWidget02(
//                 tituloPagina: 'Fale com a Ana',
//                 tituloMensagem: 'Error 01 - Erro ao Retornar Dados',
//                 corpoMensagem:
//                     'Não foi possível retornar os dados. Tente novamente.',
//                 component: 'docente',
//               );
//             } else {
//               print(snapshot.data![0]);
//               return WebPages(
//                 urlLink: snapshot.data![0].url,
//               );
//             }
//         }
//         return AlertWidget02(
//           tituloPagina: 'Fale com a Ana',
//           tituloMensagem: 'Error 02 - Erro de Conexão',
//           corpoMensagem:
//               'Não foi possível conectar com o servidor da Unisuam. Verifique sua conexão e tente novamente.',
//           component: 'docente',
//         );
//       },
//     );
//   }
// }
