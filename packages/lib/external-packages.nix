{
  inputs ? { },
  system ? null,
}:
{
  # keep-sorted start
  selexqc = inputs.selexqc.packages.${system}.selexqc or null;
  seqtable = inputs.seqtable.packages.${system}.seqtable or null;
  # keep-sorted end
}
