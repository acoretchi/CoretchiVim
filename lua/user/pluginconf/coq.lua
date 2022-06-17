-- If something fucks up here, pip install python3-venv

local status_ok, coq = pcall(require, "coq")
if not status_ok then
    return
end

vim.cmd("COQnow -s")
