library supabase_auth_ui;

import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:supabase_auth_ui/src/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthUi extends StatefulWidget{

  const SupabaseAuthUi(
      {Key? key,
        this.enabled = true,
        required this.providers,
        this.brightness = Brightness.dark,
        required this.client,
        required this.onAuthSuccess,
        required this.onAuthFailure,
        this.emailLoginEnabled = false,
      }) : super(key: key);

  final bool enabled;
  final bool emailLoginEnabled;
  final List<Provider> providers;
  final Brightness brightness;
  final SupabaseClient client;
  final Function(Session, String?) onAuthSuccess;
  final Function(String) onAuthFailure;

  @override
  State<SupabaseAuthUi> createState() => _SupabaseAuthUiState();
}

class _SupabaseAuthUiState extends State<SupabaseAuthUi> {

  bool _isLoading = false;

  // Make sure to have these controllers in your state
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if(widget.emailLoginEnabled)_emailLoginButton,
        if (widget.providers.contains(Provider.google))_googleButton,
        if (widget.providers.contains(Provider.apple))_appleButton,
        if (widget.providers.contains(Provider.facebook))_facebookButton,
        if (widget.providers.contains(Provider.github))_githubButton,
        if (widget.providers.contains(Provider.twitter))_twitterButton,
      ],
    );
  }

  Widget get _emailLoginButton => Opacity(
      opacity: widget.enabled ? 1.0 : 0.5,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              icon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              icon: Icon(Icons.lock),
            ),
            obscureText: true,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              try {
                setState(() {
                  _isLoading = true;
                });
                await AuthService.signInWithPassword(
                    widget.client,
                    email: _emailController.text,
                    password: _passwordController.text
                );
                _onAuthSuccess();
              } catch (e) {
                widget.onAuthFailure(e.toString());
              } finally {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            child: Text('Log In'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey[700],
            ),
          ),
          SizedBox(height: 10),
        ],
      )
  );

// Don't forget to dispose them
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  Widget get _googleButton => Opacity(
    opacity: widget.enabled ? 1.0 : 0.5,
    child: SignInButton(
      widget.brightness == Brightness.dark
          ? Buttons.google
          : Buttons.googleDark,
      onPressed: () async {
        try{
          setState(() {
            _isLoading = true;
          });
          String? username = await AuthService.signInWithGoogle(widget.client);
          _onAuthSuccess();
        }catch(e) {
          widget.onAuthFailure(e.toString());
        }finally{
          setState(() {
            _isLoading = false;
          });
        }
      },
    ),
  );

  Widget get _appleButton => Opacity(
    opacity: widget.enabled ? 1.0 : 0.5,
    child: SignInButton(
      widget.brightness == Brightness.dark
          ? Buttons.apple
          : Buttons.appleDark,
      onPressed: () async {
        try{
          setState(() {
            _isLoading = true;
          });
          await AuthService.signInWithApple(widget.client);
          _onAuthSuccess();
        }catch(e) {
          widget.onAuthFailure(e.toString());
        }finally{
          setState(() {
            _isLoading = false;
          });
        }
      },
    ),
  );

  Widget get _facebookButton => Opacity(
    opacity: widget.enabled ? 1.0 : 0.5,
    child: SignInButton(
      widget.brightness == Brightness.dark
          ? Buttons.facebook
          : Buttons.facebookNew,
      onPressed: () async {
        try{
          setState(() {
            _isLoading = true;
          });
          await AuthService.signInWithFacebook(widget.client);
          _onAuthSuccess();
        }catch(e) {
          widget.onAuthFailure(e.toString());
        }finally{
          setState(() {
            _isLoading = false;
          });
        }
      },
    ),
  );

  Widget get _githubButton => Opacity(
    opacity: widget.enabled ? 1.0 : 0.5,
    child: SignInButton(
      Buttons.gitHub,
      onPressed: () async {
        try{
          setState(() {
            _isLoading = true;
          });
          await AuthService.signInWithGithub(widget.client);
          _onAuthSuccess();
        }catch(e) {
          widget.onAuthFailure(e.toString());
        }finally{
          setState(() {
            _isLoading = false;
          });
        }
      },
    ),
  );

  Widget get _twitterButton => Opacity(
    opacity: widget.enabled ? 1.0 : 0.5,
    child: SignInButton(
      Buttons.twitter,
      onPressed: () async {
        try{
          setState(() {
            _isLoading = true;
          });
          await AuthService.signInWithTwitter(widget.client);
          _onAuthSuccess();
        }catch(e) {
          widget.onAuthFailure(e.toString());
        }finally{
          setState(() {
            _isLoading = false;
          });
        }
      },
    ),
  );

  void _onAuthSuccess({String? username}){
    Session? session = widget.client.auth.currentSession;
    if(session != null) {
      widget.onAuthSuccess(session, username);
    }
  }

}
