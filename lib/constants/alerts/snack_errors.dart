import 'package:flutter/material.dart';
import 'package:marvaltrainer/constants/string.dart';
import '../../widgets/marval_snackbar.dart';

//@TODO Hacer los snacks mas largos de 20secs y añadir un boton en la esquina superior derecha para cerrar el  snack.

class ThrowSnackbar{
 //Auth
    //Reset Email
  static void resetEmailError(BuildContext context){
    MarvalSnackBar(context, SNACKTYPE.alert,
        title: 'Ops, algo ha salido mal',
        subtitle: 'No hemos podido actualizar tu email, intenta de nuevo mas tarde.');
  }
  static void resetEmailSuccess(BuildContext context){
    MarvalSnackBar(context, SNACKTYPE.success,
        title: 'Todo en orden!',
        subtitle: 'Tu correo se ha actualizado con exito');
  }
    //Reset Password
  static void resetPaswordSuccess(BuildContext context){
    MarvalSnackBar(context, SNACKTYPE.success,
        title: 'Todo en orden!',
        subtitle: 'La contraseña se ha actualizado, procura que no se te olvide.');
  }
  static void resetPasswordError(BuildContext context){
    MarvalSnackBar(context, SNACKTYPE.alert,
        title: 'Ops, algo ha salido mal',
        subtitle: 'No hemos podido actualizar tu contraseña, intenta de nuevo mas tarde.');

  }
    //Sign up
  static void signUpError(BuildContext context){
    MarvalSnackBar(context, SNACKTYPE.alert,
        title: "Error al registrar usuario",
        subtitle: 'No se pudo dar de alta al usuario debido a un error inesperado. Prueba de nuevo mas tarde');
  }
  static void signUpAlreadyLoggedError(BuildContext context){
    MarvalSnackBar(context, SNACKTYPE.alert,
        title: "Error al registrar usuario",
        subtitle: 'El email proporcionado ya se encuentra actualmente registrado en la base de datos');
  }
  static void signUpSuccess(BuildContext context){
    MarvalSnackBar(context, SNACKTYPE.success,
        title: "Usuario registrado con exito",
        subtitle: 'Ya puedes configurar el entrenamiento del usuario.'
    );
  }

  //Habits Page
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

  // Firebase Storage
      //Images
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


  // IMAGES
  static void imageError(BuildContext context){
    MarvalSnackBar(context, SNACKTYPE.alert,
        title: "Ups, algo ha fallado",
        subtitle: "No se ha podido seleccionar la imagen"
    );
  }

}