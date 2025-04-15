// @ts-check
import { defineConfig } from "astro/config";
import starlight from "@astrojs/starlight";

// https://astro.build/config
export default defineConfig({
  site: "https://stablercharacter.github.io",
  base: "StoryTailor",
  integrations: [
    starlight({
      title: "StoryTailor",
      editLink: {
        baseUrl: "https://github.com/StablerCharacter/StoryTailor/edit/master/docs/"
      },
      social: [
        {
          icon: "github",
          label: "GitHub",
          href: "https://github.com/StablerCharacter/StoryTailor",
        },
      ],
      sidebar: [
        {
          label: "Start Here",
          items: [{ label: "Introduction", slug: "intro/introduction" }],
        },
        {
          label: "Guides",
          autogenerate: { directory: "guides" },
        },
        {
          label: "Stages",
          items: [
            {
              label: "Stages", slug: "stages/stages"
            },
            { label: "Main Menu Stage", slug: "stages/main-menu-stage" },
            { label: "Story Stage", slug: "stages/story-stage" },
            { label: "Credits Stage", slug: "stages/credits-stage" }
          ]
        },
        {
          label: "Reference",
          autogenerate: { directory: "reference" },
        },
      ],
    }),
  ],
});
