import 'package:flutter/material.dart';

import '../widgets/marval_snackbar.dart';


class ThrowSnackbar{


  static void habitUpdateError(BuildContext context){
    MarvalSnackBar(context, SNACKTYPE.alert,
        title: "Ups, algo ha fallado",
        subtitle: "Parece que el habito no se ha podido actualizar, intenta de nuevo mas tarde."
    );
  }

  static void habitUpdateSuccess(BuildContext context){
    MarvalSnackBar(context, SNACKTYPE.success,
        title: "Habito actualizado! ",
        subtitle: "Estos cambios se veran reflejados al volver a asignar el habito a cada usuario."
    );
  }
  static void deleteHabitError(BuildContext context){
    MarvalSnackBar(context, SNACKTYPE.alert,
        title: "Paso a paso",
        subtitle: "Primero debes deseleccionar a todos los usuarios"
    );
  }

  static void downloadError(BuildContext context){
    MarvalSnackBar(context, SNACKTYPE.alert,
        title: "Ups, algo ha fallado",
        subtitle: "No se ha podido realizar la descarga"
    );
  }

  static void downloadSuccess(BuildContext context){
    MarvalSnackBar(context, SNACKTYPE.success,
        title: "Descarga completa!",
        subtitle: "El archivo se ha descargado con exito"
    );
  }

  static void imageError(BuildContext context){
    MarvalSnackBar(context, SNACKTYPE.alert,
        title: "Ups, algo ha fallado",
        subtitle: "No se ha podido seleccionar la imagen"
    );
  }

}