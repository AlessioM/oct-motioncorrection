ddisp('LOG_RESET');
ddisp('starting');
pause(0.5);
ddisp('first big step');
pause(2);
ddisp('first V2');
pause(2);
numSteps = 5;
ddisp('second step with %d substeps', numSteps);
for i = 1:numSteps
    ddisp([i,numSteps], 'sub step');
    pause(0.5);
    ddisp([], 'other sub step');
    pause(0.5);
end

ddisp('third step with %d substeps', numSteps);
for i = 1:numSteps
    ddisp([], 'sub step with format %d', i * 100);
    pause(0.5);
    ddisp([], 'other sub step');
    pause(0.5);
end

ddisp('done');