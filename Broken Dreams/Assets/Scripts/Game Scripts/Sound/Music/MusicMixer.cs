using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MusicMixer : MonoBehaviour {

    private AudioSource source;
    public AudioClip[] mainSongs;
    public bool playOnAwake;
    public AudioClip enemyChase;
 //   public AudioClip enemyLost;
 //   public AudioClip enemyCaught;

    //Enemies
    public static int enemiesChasing = 0;

    //Info
    int rand;

    void Awake()
    {
        source = GetComponent<AudioSource>();
        if (playOnAwake)
            playRandomRegularTrack();
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

    /* void handleMainEnemy()
    {
        if (enemy != null && enemy.health > 0 && PlayerHealth.health > 0)
        {
            if (!enemy.isChasing() && !enemy.isSearching() && enemy.isNearPlayer(10) && source.clip != enemyNear)
            {
                source.clip = enemyNear;
                play();
            }

            else if (enemy != null && enemy.isChasing() && source.clip != enemyChase)
            {
                source.clip = enemyChase;
                play();
            }

            else if (enemy != null && enemy.isSearching() && source.clip != enemySearch)
            {
                source.clip = enemySearch;
                play();
            }

            else if (!isPlayingRandomTrack())
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

    } */

    public void playRandomRegularTrack()
    {
        if (source.clip == enemyChase)
        {
            source.Stop();
            source.clip = null;
        }
        rand = Random.Range(0,mainSongs.Length);
        //Debug.Log(rand);
        source.clip = mainSongs[rand];
        source.Play();
    }

    bool isPlayingRandomTrack()
    {
        for(int i = 0; i < mainSongs.Length; i++)
        {
            if (source.clip == mainSongs[i])
            {
                return true;
            }
        }

        return false;
    }

    void Update()
    {
        Debug.Log("ENEMIES CHASING : " + enemiesChasing);

        if (!isPlayingRandomTrack() && enemiesChasing == 0)
            playRandomRegularTrack();

        else if(source.clip != enemyChase && enemiesChasing > 0)
        {
            chaseScore();
        }
        else if(PlayerHealth.health <= 0)
        {
            source.Stop();
            enemiesChasing = 0;
        }

        //Error Fix
        if (enemiesChasing < 0)
            enemiesChasing = 0;
    }

    public void chaseScore()
    {
        source.Stop();
        source.clip = enemyChase;
        source.Play();
    }

    /*

    public void lostScore()
    {
        source.Stop();
        source.clip = enemyLost;
        source.Play();
    }

    public void caughtScore()
    {
        source.Stop();
        source.clip = enemyCaught;
        source.Play();
    }

    */
}
