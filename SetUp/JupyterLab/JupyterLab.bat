call %ANACONDADIR%\Anaconda3\Scripts\activate.bat
call %ANACONDADIR%\Anaconda3\condabin\conda activate %ANACONDAENVIRONMENT%
cd /d %RESEARCHDIR%
jupyter lab
