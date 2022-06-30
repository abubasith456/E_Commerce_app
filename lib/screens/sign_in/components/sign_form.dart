import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/bloc/login_bloc/bloc/login_bloc.dart';
import 'package:shop_app/components/custom_surfix_icon.dart';
import 'package:shop_app/components/form_error.dart';
import 'package:shop_app/db/userDB.dart';
import 'package:shop_app/helper/keyboard.dart';
import 'package:shop_app/models/user_db_model.dart';
import 'package:shop_app/screens/forgot_password/forgot_password_screen.dart';
import 'package:shop_app/screens/home/home_screen.dart';
import 'package:shop_app/util/shared_pref.dart';
import '../../../components/default_button.dart';
import '../../../constants.dart';
import '../../../db/db_services.dart';
import '../../../util/size_config.dart';
import '../../../db/userDB.dart';

class SignForm extends StatefulWidget {
  @override
  _SignFormState createState() => _SignFormState();
}

class _SignFormState extends State<SignForm> {
  final _formKey = GlobalKey<FormState>();
  String? email;
  String? password;
  bool? remember = false;
  bool isLoading = false;
  final List<String?> errors = [];
  LoginBloc _loginBloc = LoginBloc();
  // var _userService = UserService();
  var sharedPref = SharedPref();

  void addError({String? error}) {
    if (!errors.contains(error))
      setState(() {
        errors.add(error);
      });
  }

  void removeError({String? error}) {
    if (errors.contains(error))
      setState(() {
        errors.remove(error);
      });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) async {
        if (state is ErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
            ),
          );
          setState(() {
            isLoading = false;
          });
        } else if (state is LoadingState) {
          print('LoadingState called');
        } else if (state is LoadedState) {
          print('LoadedState called');
          print(state.loginModel);
          if (state.loginModel.status == 200) {
            Navigator.pushNamed(context, HomeScreen.routeName);
            sharedPref.setBoolValue(loggedKey, true);
            sharedPref.setStringValue(
                emailKey, state.loginModel.userData!.email!);
            sharedPref.setStringValue(
                userIdKey, state.loginModel.userData!.userId!.toString());

            var user = User(
                userId: state.loginModel.userData!.userId!.toString(),
                password: password!,
                email: state.loginModel.userData!.email!,
                name: state.loginModel.userData!.username!);

            UserDb.instance.create(user);
            // BlocProvider.of<LoginBloc>(context)
            //     .close()
            //     .then((value) => print('Login page closed'));
          } else if (state.loginModel.status == 400) {
            showDialog(context, 'Failed', state.loginModel.message!);
            setState(() {
              isLoading = false;
            });
          }
        }
      },
      // child: BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              buildEmailFormField(),
              SizedBox(height: getProportionateScreenHeight(30)),
              buildPasswordFormField(),
              SizedBox(height: getProportionateScreenHeight(30)),
              Row(
                children: [
                  // Checkbox(
                  //   value: remember,
                  //   activeColor: kPrimaryColor,
                  //   onChanged: (value) {
                  //     setState(() {
                  //       remember = value;
                  //     });
                  //   },
                  // ),
                  // Text("Remember me"),
                  Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(
                        context, ForgotPasswordScreen.routeName),
                    child: Text(
                      "Forgot Password",
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
                  )
                ],
              ),
              FormError(errors: errors),
              SizedBox(height: getProportionateScreenHeight(20)),
              DefaultButton(
                text: "Continue",
                isLoading: isLoading,
                press: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    setState(() {
                      errors.clear();
                      isLoading = true;
                    });
                    BlocProvider.of<LoginBloc>(context)
                        .add(LoginUser(email: email!, password: password!));
                    KeyboardUtil.hideKeyboard(context);
                  }
                },
              ),
            ],
          ),
        );
      },
      // ),
    );
  }

  TextFormField buildPasswordFormField() {
    return TextFormField(
      obscureText: true,
      onSaved: (newValue) => password = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPassNullError);
        } else if (value.length >= 8) {
          removeError(error: kShortPassError);
        }
        return null;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kPassNullError);
          return "";
        } else if (value.length < 8) {
          addError(error: kShortPassError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Password",
        hintText: "Enter your password",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Lock.svg"),
      ),
    );
  }

  TextFormField buildEmailFormField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      onSaved: (newValue) => email = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kEmailNullError);
        } else if (emailValidatorRegExp.hasMatch(value)) {
          removeError(error: kInvalidEmailError);
        }
        return null;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kEmailNullError);
          return "";
        } else if (!emailValidatorRegExp.hasMatch(value)) {
          addError(error: kInvalidEmailError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Email",
        hintText: "Enter your email",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Mail.svg"),
      ),
    );
  }

  Future<OkCancelResult> showDialog(
      BuildContext context, String title, String message) {
    return showOkAlertDialog(
      context: context,
      title: title,
      message: message,
    );
  }
}
