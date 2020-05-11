Facter.add("addomain") do
  $ad_cmd = `powershell -command "(Get-ADDomain).NetBiosName" 2>$null`
  $ad_cmd = $ad_cmd.gsub(/\n/,'')

  setcode do
    $ad_cmd
  end
end
