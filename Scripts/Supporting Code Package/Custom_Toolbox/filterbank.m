%This function filteres the given signal through different band passes as
%defined with the frequency range and the given number of bands
%
%Input:
%   sig ......... The given signal to filter in the dimension of
%                   [number of datapoints] x [number of channels]
%   num_bands ... The number of bands the signal should be split into, e.g.
%                   num_bands = 10 produces 10 frequency bands
%   range ....... The frequency range in which the bands should be, e.g.
%                   range = [1 40] means that the number of bands are
%                   equidistantly spaced across this frequency range
%   fs .......... The sampling frequency of the input signal
%
%Output:
%   sig_filtered ... The filtered signal split into the frequency bands
%                   [number of datapoints] x [number of channels] x [number of frequency bands]
%   freq_bands ..... The frequency bands the signal is split into for
%                   easier further processing
%
%Dependencies: none


function [sig_filtered, freq_bands] = filterbank(sig, num_bands, range, fs)
  %Creating frequency bands at which splits should happen
  freq_bands = linspace(range(1), range(2), num_bands + 1);
  %Preallocating space for filtered signals
  sig_filtered = zeros(size(sig, 1), size(sig, 2), num_bands);
  %If the splits should happen from 0, put the lower frequency to 0.01,
  %otherwise the bandpass can not be constructed
  if(freq_bands(1) == 0)
      freq_bands(1) = 0.01;
  end
  %Filtering loop
  for cnt = 1:num_bands
      %Designing filter parameters (not to high order to not make filter
      %unstable)
      [b ,a] = butter(2, [freq_bands(cnt) freq_bands(cnt + 1)] ./(fs / 2), ...
          'bandpass');
      %Filtering signal by parameters
      sig_filtered(:, :, cnt) = filtfilt(b, a, sig);
  end
end
