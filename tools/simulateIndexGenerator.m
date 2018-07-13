% Karma/tools/simulateIndexGenerator.m
% Nicholas Killeen,
% 13th July 2018.
% Main routine to simulate theoretical percentiles arising from the index
% generator specified in defineIndexGenerator.m.
%
% See the Perl Karma classes 'indexGenerator' property documentation for 
% context.

% Configuration.
N = 10000;           % Number of samples to generate.

n = 20;              % Number of indexes in the cycle.

d = 100;             % Discretisation interval; the percentiles will be
                     % calculated at 0, 1/d, 2/d, ..., (d-1)/d, 1.
                     
printText = 1;       % Should we print the d points we are graphing to the
                     % screen? Turn off for large d.
                     
% Import T and Ti from defineIndexGenerator.m.
defineIndexGenerator;

% Predeclare some loop variables so that MATLAB can set aside space for them.
p = 0:1/d:1;             % Percentiles.
P = zeros(1, length(p)); % Prob(G in top p-percentile).
L = zeros(1, length(p)); % Estimated lower bounds for P.
U = zeros(1, length(p)); % Estimated upper bounds for P.
c = zeros(1, length(p)); % 1 or 0; does p lie in our estimated region [L, U]?

                     
% Simulate N indexGenerator calls.
Uniform = rand(1, N);      % Uniform random sample of length N.
G = floor(T(Uniform) * n); % Random sample of N indexes chosen by indexGenerator.

% For each percentile, calculate (and optionally print) the associated P, L, U,
% and c.
if (printText)
    fprintf("   p          P          L          U       c\n");
end
for i=1:length(p)
    P(i) = sum(G <= n*p(i)) / N; % Percentage of the N generated indexes within
                                 % the p(i)th percentile of the n possible
                                 % indexes to generate.
                                 
    L(i) = Ti(p(i));
    U(i) = Ti(p(i) + 1/n);
    c(i) = L(i) <= P(i) && P(i) <= U(i);

    if (printText)
        fprintf("%.5f    %.5f    %.5f    %.5f    %d\n" ...
            , p(i), P(i), L(i), U(i), c(i));
    end
end

% Plot the graph.
figure;
plot(p, P, 'k', ...
     p, L, 'r', ...
     p, U, 'g', ...
     p.*c, 1.1, 'g.', ...  % Plot green dots at the height 1.1 when L <= P <= U;
     p.*(1-c), 1.1, 'rx'); % Plot red crosses at that height otherwise.
legend("P", "L", "U", 'location', 'southeast');


