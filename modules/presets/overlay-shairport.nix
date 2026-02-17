{ final, prev }:
{
  shairport-sync = prev.shairport-sync.override {
    withPulseaudio = false;
  };
}
