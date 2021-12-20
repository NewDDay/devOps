# Maker Julia images

To run my scripts I need julia image with some packages. The list of these packages may vary. In order to automate this process, I created this script. The picture below shows the principle of its operation.

![JuliaImageMakingScheme](https://github.com/NewDDay/devOps/blob/main/mkJuliaImage/JuliaImageMaking.png?raw=true)

# In order to create julia image yourself, you need:
- Write a list of required packages in install.jl and forImageTest.jl
- Run mkDockerImage.sh
- If you saw the Data Frame, then you did it
