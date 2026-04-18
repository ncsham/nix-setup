# SSH config snippets (work vs personal identity).
{ ... }:
{
  home.file.".ssh/config_work".text = ''
    Host github.com
      AddKeysToAgent yes
      UseKeychain yes
      IdentityFile ~/.ssh/id_ed25519_work
  '';
  home.file.".ssh/config_personal".text = ''
    Host github.com
      AddKeysToAgent yes
      UseKeychain yes
      IdentityFile ~/.ssh/id_ed25519
  '';
}
