function lsize --wraps='eza -lAh --total-size --sort=size' --description 'alias lsize eza -lAh --total-size --sort=size'
    eza -lAh --total-size --sort=size $argv
end
