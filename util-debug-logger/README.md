# debug output utility

## features
* this is a drop in replacement for the disp function
* it adds the total script time and the time since the last call
* supports sub messages (see example)

## usage

```
ddisp('LOG_RESET');
ddisp('starting');

ddisp('first big step');

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
```

### output during execution

    [   0.0 |    0.0]: starting
    [   0.5 |    0.0]: first big step
    [   4.0 |    3.5]: second step with 5 substeps [0.80]: other sub step

### total output 

    [   0.0 |    0.0]: starting
    [   0.5 |    0.0]: first big step
    [   5.0 |    4.5]: second step with 5 substeps
    [  10.1 |    4.6]: third step with 5 substeps
    [  10.6 |    0.0]: done