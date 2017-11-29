using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MusicMixer : MonoBehaviour {

    private AudioSource source;
    public AudioClip[] mainSongs;
    public bool playOnAwake;
    public bool hasMainEnemy;
    public Antagonist enemy;
    public AudioClip enemyNear;
    public AudioClip enemyChase;
    public AudioClip enemySearch;

    void Awake()
    {
        source = GetComponent<AudioSource>();
        if (playOnAwake)
            play();
    }

    public void pause()
    {
        source.Pause();
    }

    public void play()
    {
        if(!source.isPlaying)
        source.Play();
    }

    void handleMainEnemy()
    {
        if (enemy.health > 0 && PlayerHealth.health > 0)
        {
            if (!enemy.isChasing() && !enemy.isSearching() && enemy.isNearPlayer(10) && source.clip != enemyNear)
            {
                source.clip = enemyNear;
                play();
            }

            else if (enemy.isChasing() && source.clip != enemyChase)
            {
                source.clip = enemyChase;
                play();
            }

            else if (enemy.isSearching() && source.clip != enemySearch)
            {
                source.clip = enemySearch;
                play();
            }

            else if (isPlayingRandomTrack())
            {
                playRandomRegularTrack();
                play();
            }
        }
        else
        {
            //playRandomRegularTrack();
            pause();
        }

    }

    void playRandomRegularTrack()
    {
        int rand = Random.Range(0,mainSongs.Length + 1);
        source.clip = mainSongs[rand];
    }

    bool isPlayingRandomTrack()
    {
        bool temp = false;

        for(int i = 0; i < mainSongs.Length; i++)
        {
            if (source.clip == mainSongs[i])
            {
                temp = true;
                break;
            }
        }

        return temp;
    }

    void Update()
    {

        Debug.Log(source.isPlaying);
        if (hasMainEnemy)
            handleMainEnemy();
    }
}
