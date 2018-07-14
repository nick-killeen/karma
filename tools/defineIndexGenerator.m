% Karma/tools/defineIndexGenerator.m
% Nicholas Killeen,
% 13th July 2018.
% Defines a transform T: [0, 1) -> [0, 1) and the associated inverse transform
% Ti to be exported to simulateIndexGenerator.m.

a = 5;
b = 0.8;
T = @(x) (((1/pi)*asin(2.*(x).^(a) - 1) + 1/2)).^b;
Ti = @(y) ((sin((pi.*(y.^(1/b)) - pi/2)) + 1) / 2).^(1/a);
