function inss = instances_for_initial_template(M,candi_count,wind_size,fix_ins,reduce_size,python2path)

% setenv('PATH', ['/usr/bin', pathsep, getenv('PATH')])
% setenv('PATH', ['home/judng/miniconda3/bin', pathsep, getenv('PATH')]) % please adapt it to your own python address
% setenv('PATH', ['/Users/junningdeng/anaconda/bin', pathsep, getenv('PATH')])
setenv('PATH', [python2path, pathsep, getenv('PATH')])
csvwrite('M.csv',M);

pwd;

if fix_ins == 'n'
    commandStr = ['python /simit/cp_full.py', ' M.csv', cell2mat(strcat({' '},int2str(candi_count))), cell2mat(strcat({' '},int2str(wind_size)))];
    system(commandStr);
else
    commandStr = ['python /simit/cp_pruned.py', ' M.csv', cell2mat(strcat({' '},int2str(candi_count))), cell2mat(strcat({' '},int2str(wind_size))), cell2mat(strcat({' '},int2str(reduce_size))) ];
    system(commandStr);
end

inss = csvread('inss.csv');

inss = [inss]+1;