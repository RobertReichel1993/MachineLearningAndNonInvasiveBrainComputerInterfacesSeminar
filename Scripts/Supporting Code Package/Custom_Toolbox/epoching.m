function [epochs] = epoching(data,markers,trials)
n = ones(4,1);
Ref = 2;        % Reference marker
Im = 4;         % Imagine marker
H = 1;          % Hand trial
F = 2;          % Feet trial

for i = 1:length(markers)
    if markers(2,i) == Ref          % If indicates reference...
        if trials(2,i) == H         % ... and hand.
            epochs.RefEEGH(:,:,n(1)) = data(:,markers(1,i):markers(1,i+1));


            n(1) = n(1)+1;
        else                        % ... and feet.
            epochs.RefEEGF(:,:,n(2)) = data(:,markers(1,i):markers(1,i+1));
            n(2) = n(2)+1;
        end
    elseif markers(2,i) == Im       % If indicates imaginary part...
        if trials(2,i) == H         % ... and hand.
            epochs.ImEEGH(:,:,n(3)) = data(:,markers(1,i):markers(1,i+1));
            n(3) = n(3)+1;
        else                        % ... and feet.
            epochs.ImEEGF(:,:,n(4)) = data(:,markers(1,i):markers(1,i+1));
            n(4) = n(4)+1;
        end
    end
end
end

