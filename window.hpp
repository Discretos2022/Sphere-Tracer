#include <SDL2/SDL.h>
#include <SDL2/SDL_pixels.h>
#include <SDL2/SDL_render.h>
#include <iostream>
#include <vector>


class Window
{

    public:
        Window()
        {

        }

        ~Window()
        {
            destroy();
        }


        bool initialize()
        {

            if (SDL_Init(SDL_INIT_VIDEO) < 0)
            {
                std::cerr << "SDL initilization failed : " << SDL_GetError() << "\n";
                return false;
            }

            std::string title = "Disc Tracer 1.0";

            window = SDL_CreateWindow(title.c_str(), SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 800, 600, SDL_WINDOW_SHOWN); // | SDL_WINDOW_RESIZABLE
            if (!window)
            {
                std::cerr << "Window creation failed :" << SDL_GetError() << "\n";
                destroy();
                return false;
            }

            renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
            if (!renderer)
            {
                std::cerr << "Renderer creation failed : " << SDL_GetError() << "\n";
                destroy();
                return false;
            }

            texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGB24, SDL_TEXTUREACCESS_STREAMING, 800, 600);
            if (!texture)
            {
                std::cerr << "Texture creation failed : " << SDL_GetError() << "\n";
                destroy();
                return false;
            }


            return true;
        }

        void destroy()
        {

            if (texture)
            {
                SDL_DestroyTexture(texture);
                texture = nullptr;
            }

            if (renderer)
            {
                SDL_DestroyRenderer(renderer);
                renderer = nullptr;
            }

            if (window)
            {
                SDL_DestroyWindow(window);
                window = nullptr;
            }

            SDL_Quit();
        }


        void update(const std::vector<unsigned char> &image)
        {

            SDL_UpdateTexture(texture, nullptr, image.data(), 800 * 3);
            SDL_RenderClear(renderer);
            const SDL_Rect image_rect = { 0, 0, 800, 600 };  //imageDestRect();
            SDL_RenderCopy(renderer, texture, nullptr, &image_rect);

        }

        void present()
        {
            SDL_RenderPresent(renderer);
        }


        static bool pollEvent(SDL_Event &event)
        {
            bool has_event = SDL_PollEvent(&event);
            return has_event;
        }



    private:
        SDL_Window *window;
        SDL_Renderer *renderer;
        SDL_Texture *texture;

};