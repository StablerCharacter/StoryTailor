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
          label: "Reference",
          autogenerate: { directory: "reference" },
        },
      ],
    }),
  ],
});
