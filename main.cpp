#include <iostream>
#include <SDL2/SDL.h>
#include <vector>
#include "window.hpp"
#include "camera.hpp"


int main()
{

    std::cout << "Disc Tracer 1.0" << "\n";


    Window window;
    Camera camera({0,0,0}, 800, 600, 3);

    if (!window.initialize())
    {
        return -1;
    }

    bool running = true;

    std::vector<unsigned char> image;
    for (int i = 0; i < 800 * 600; i++)
    {
        image.push_back(0);
        image.push_back(255);
        image.push_back(255);
    }

    camera.render(image);

    while (running) {
        
        SDL_Event event;
    
        while(window.pollEvent(event)) {
    
            if (event.type == SDL_QUIT || (event.type == SDL_KEYDOWN && event.key.keysym.sym == SDLK_ESCAPE))
            {
                running = false;
            }
    
        }

        window.update(image);
        window.present();

    }

    
    
    std::cout << "Disc Tracer Exited !" << "\n";

}
